import Foundation
import GRDB

enum RecipeServiceError: Error, LocalizedError {
    case recipeNotFound(id: Int64)
    case productForRecipeNotFound(id: Int64)
    case ingredientCostInvalid(name: String)
    case negativeQuantity
    case circularReference(path: [String])
    case databaseError(Error)
    
    var errorDescription: String? {
        switch self {
        case .recipeNotFound(let id):
            return "A receita com ID \(id) não foi encontrada."
        case .productForRecipeNotFound(let id):
            return "O produto associado à receita (ID: \(id)) não foi encontrado."
        case .ingredientCostInvalid(let name):
            return "O ingrediente '\(name)' tem um custo inválido ou não definido."
        case .negativeQuantity:
            return "A quantidade de um ingrediente não pode ser negativa ou zero."
        case .circularReference(let path):
            return "Referência circular detectada: \(path.joined(separator: " -> ")). Uma receita não pode ser ingrediente de si mesma."
        case .databaseError(let error):
            return "Erro no banco de dados: \(error.localizedDescription)"
        }
    }
}


class RecipeService {
    
    private let recipeRepo: RecipeRepository
    private let ingredientRepo: RecipeIngredientRepository
    private let productRepo: ProductRepository
    private let dbPool: DatabasePool

    init(
        recipeRepo: RecipeRepository = RecipeRepositoryImpl(),
        ingredientRepo: RecipeIngredientRepository = RecipeIngredientRepositoryImpl(),
        productRepo: ProductRepository = ProductRepositoryImpl(),
        dbPool: DatabasePool = DatabaseManager.shared.dbPool
    ) {
        self.recipeRepo = recipeRepo
        self.ingredientRepo = ingredientRepo
        self.productRepo = productRepo
        self.dbPool = dbPool
    }
    
    func getById(_ id: Int64) async throws -> Recipe {
        guard let recipe = try await recipeRepo.get(id: id) else {
            throw RecipeServiceError.recipeNotFound(id: id)
        }
        return recipe
    }
    
    func getRecipeWithIngredients(id: Int64) async throws -> (Recipe, [RecipeIngredient]) {
        let recipe = try await getById(id)
        let ingredients = try await ingredientRepo.getByRecipeId(recipeId: id)
        return (recipe, ingredients)
    }
    
    func save(recipe: inout Recipe, ingredients: [RecipeIngredient]) async throws {
        for ingredient in ingredients {
            if ingredient.quantity <= 0 {
                throw RecipeServiceError.negativeQuantity
            }
        }
        
        try await dbPool.writeInTransaction { db in
            try recipe.save(db)
            
            try RecipeIngredient.deleteAll(db, request: RecipeIngredient.filter(RecipeIngredient.Columns.recipeId == recipe.id))
            for var ingredient in ingredients {
                ingredient.recipeId = recipe.id
                try ingredient.save(db)
            }
            
            return .commit
        }
        
        // After saving, trigger the cost recalculation
        if let recipeId = recipe.id {
            try await recalculateCost(for: recipeId)
        }
    }
    
    func delete(recipe: Recipe) async throws {
        _ = try await recipeRepo.delete(id: recipe.id!)
    }
    
    @discardableResult
    func recalculateCost(for recipeId: Int64) async throws -> Decimal {
        var visited = Set<Int64>()
        return try await dbPool.writeInTransaction { db in
            try await self.recalculateCost(for: recipeId, db: db, visited: &visited)
        }
    }
    
    private func recalculateCost(for recipeId: Int64, db: Database, visited: inout Set<Int64>) async throws -> Decimal {
        guard try await db.exists(Recipe.filter(key: recipeId)) else {
            throw RecipeServiceError.recipeNotFound(id: recipeId)
        }
        
        // Circular reference check
        if visited.contains(recipeId) {
            // To provide a useful error, we'd need to trace the path.
            // For now, we just throw a generic cycle error.
            throw RecipeServiceError.circularReference(path: [])
        }
        visited.insert(recipeId)

        var totalCost: Decimal = 0
        let ingredients = try await RecipeIngredient
            .filter(RecipeIngredient.Columns.recipeId == recipeId)
            .fetchAll(db)

        for ingredient in ingredients {
            guard let product = try await Product.fetchOne(db, key: ingredient.productId) else {
                throw RecipeServiceError.productForRecipeNotFound(id: ingredient.productId)
            }

            var ingredientCost: Decimal
            
            switch product.type {
            case .rawMaterial:
                guard let purchasePrice = product.purchasePrice else {
                    throw RecipeServiceError.ingredientCostInvalid(name: product.name)
                }
                ingredientCost = purchasePrice
            
            case .manufactured:
                // If the ingredient is another recipe, recursively calculate its cost
                guard let subRecipeId = product.recipeId else {
                     throw RecipeServiceError.ingredientCostInvalid(name: product.name)
                }
                ingredientCost = try await recalculateCost(for: subRecipeId, db: db, visited: &visited)
            }
            
            totalCost += ingredient.quantity * ingredientCost
        }
        
        // Update the recipe's totalCost in the database
        try await db.execute(
            sql: "UPDATE recipe SET totalCost = ? WHERE id = ?",
            arguments: [totalCost, recipeId]
        )
        
        // Backtrack for other branches of the calculation
        visited.remove(recipeId)
        
        return totalCost
    }
}
