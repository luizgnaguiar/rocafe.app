import Foundation
import GRDB

@MainActor
class RecipeService {
    
    private let recipeRepo: RecipeRepository
    private let ingredientRepo: RecipeIngredientRepository
    private let productRepo: ProductRepository

    init(
        recipeRepo: RecipeRepository = RecipeRepositoryImpl(),
        ingredientRepo: RecipeIngredientRepository = RecipeIngredientRepositoryImpl(),
        productRepo: ProductRepository = ProductRepositoryImpl()
    ) {
        self.recipeRepo = recipeRepo
        self.ingredientRepo = ingredientRepo
        self.productRepo = productRepo
    }
    
    func getById(_ id: Int64) async throws -> Recipe {
        guard let recipe = try await Task({ try recipeRepo.get(id: id) }).value else {
            throw RecipeServiceError.notFound
        }
        return recipe
    }
    
    func getIngredientsForRecipe(recipeId: Int64) async throws -> [RecipeIngredient] {
        try await Task {
            try ingredientRepo.getByRecipeId(recipeId: recipeId)
        }.value
    }
    
    func getRecipeWithIngredients(id: Int64) async throws -> (Recipe, [RecipeIngredient]) {
        let recipe = try await getById(id)
        let ingredients = try await getIngredientsForRecipe(recipeId: id)
        return (recipe, ingredients)
    }
    
    func save(recipe: inout Recipe, ingredients: [RecipeIngredient]) async throws {
        // Validation
        for ingredient in ingredients {
            if ingredient.quantity <= 0 {
                throw RecipeServiceError.negativeQuantity
            }
        }
        
        var recipeToSave = recipe
        let ingredientsToSave = ingredients
        
        // The transaction logic is more complex than a simple Task.value wrapper.
        // It's better to perform this in a single Task that manages the transaction.
        try await Task {
            try recipeRepo.dbPool.writeInTransaction { db in
                try recipeToSave.save(db)
                
                try RecipeIngredient.deleteAll(db, request: RecipeIngredient.filter(RecipeIngredient.Columns.recipeId == recipeToSave.id))
                for var ingredient in ingredientsToSave {
                    ingredient.recipeId = recipeToSave.id
                    try ingredient.save(db)
                }
                
                return .commit
            }
        }.value
        
        recipe = recipeToSave
        
        // After saving, trigger the cost recalculation
        if let recipeId = recipe.id {
            try await recalculateCost(for: recipeId)
        }
    }
    
    func delete(recipe: Recipe) async throws {
        guard let recipeId = recipe.id else { return }
        let success = try await Task {
            try recipeRepo.delete(id: recipeId)
        }.value
        if !success {
            throw RecipeServiceError.deleteFailed
        }
    }
    
    // NOTE: This recalculation logic is inherently async and complex.
    // It's better to leave it as a direct async method rather than wrapping
    // smaller parts in Task {}.value, as it needs to manage its own recursion
    // and database transaction. The implementation from the previous step is kept.
    @discardableResult
    func recalculateCost(for recipeId: Int64) async throws -> Decimal {
        var visited = Set<Int64>()
        return try await recipeRepo.dbPool.writeInTransaction { db in
            try await self.recalculateCost(for: recipeId, db: db, visited: &visited)
        }
    }
    
    private func recalculateCost(for recipeId: Int64, db: Database, visited: inout Set<Int64>) async throws -> Decimal {
        guard try await db.exists(Recipe.filter(key: recipeId)) else {
            throw RecipeServiceError.notFound
        }
        
        if visited.contains(recipeId) {
            throw RecipeServiceError.circularReference
        }
        visited.insert(recipeId)

        var totalCost: Decimal = 0
        let ingredients = try await RecipeIngredient.filter(RecipeIngredient.Columns.recipeId == recipeId).fetchAll(db)

        for ingredient in ingredients {
            let product = try await productRepo.get(id: ingredient.productId)
            
            var ingredientCost: Decimal
            
            switch product?.type {
            case .rawMaterial:
                guard let purchasePrice = product?.purchasePrice else {
                    throw RecipeServiceError.ingredientCostInvalid(name: product?.name ?? "Unknown")
                }
                ingredientCost = purchasePrice
            
            case .manufactured:
                guard let subRecipeId = product?.recipeId else {
                     throw RecipeServiceError.ingredientCostInvalid(name: product?.name ?? "Unknown")
                }
                ingredientCost = try await recalculateCost(for: subRecipeId, db: db, visited: &visited)
            
            case .none:
                throw RecipeServiceError.ingredientCostInvalid(name: product?.name ?? "Unknown")
            }
            
            totalCost += ingredient.quantity * ingredientCost
        }
        
        try await db.execute(sql: "UPDATE recipe SET totalCost = ? WHERE id = ?", arguments: [totalCost, recipeId])
        visited.remove(recipeId)
        return totalCost
    }
}


enum RecipeServiceError: LocalizedError {
    case notFound
    case ingredientCostInvalid(name: String)
    case negativeQuantity
    case circularReference
    case deleteFailed
    
    var errorDescription: String? {
        switch self {
        case .notFound:
            return "A receita não foi encontrada."
        case .ingredientCostInvalid(let name):
            return "O ingrediente '\(name)' tem um custo inválido ou não definido."
        case .negativeQuantity:
            return "A quantidade de um ingrediente não pode ser negativa ou zero."
        case .circularReference:
            return "Referência circular detectada em uma receita."
        case .deleteFailed:
            return "Falha ao deletar a receita."
        }
    }
}