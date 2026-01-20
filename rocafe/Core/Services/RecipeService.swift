import Foundation
import GRDB

enum RecipeServiceError: Error, LocalizedError {
    case recipeNotFound(id: Int64)
    case productForRecipeNotFound(id: Int64)
    case ingredientNotFound(id: Int64)
    case negativeQuantity
    case circularReference(path: [String])
    case databaseError(Error)
    
    var errorDescription: String? {
        switch self {
        case .recipeNotFound(let id):
            return "A receita com ID \(id) não foi encontrada."
        case .productForRecipeNotFound(let id):
            return "O produto associado à receita (ID: \(id)) não foi encontrado."
        case .ingredientNotFound(let id):
            return "O ingrediente com ID \(id) não foi encontrado."
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
    
    private let dbQueue: DatabaseQueue
    
    init(dbQueue: DatabaseQueue = DatabaseManager.shared.dbQueue) {
        self.dbQueue = dbQueue
    }
    
    /// Saves a recipe and its ingredients within a single transaction.
    func save(recipe: inout Recipe, ingredients: [RecipeIngredient]) throws {
        
        for ingredient in ingredients {
            if ingredient.quantity <= 0 {
                throw RecipeServiceError.negativeQuantity
            }
            // Further validation for ingredient existence can be added here.
        }
        
        try dbQueue.writeInTransaction { db in
            try recipe.save(db)
            
            // Delete old ingredients and save new ones
            try RecipeIngredient.deleteAll(db, request: RecipeIngredient.filter(RecipeIngredient.Columns.recipeId == recipe.id))
            for var ingredient in ingredients {
                ingredient.recipeId = recipe.id
                try ingredient.save(db)
            }
            
            // The cost should be recalculated after saving
            return .commit
        }
    }
    
    /// Recursively recalculates the cost of a recipe and all parent recipes that use it.
    /// This should be run in a background thread to avoid blocking the UI.
    func recalculateCost(for recipeId: Int64) async throws {
        // --- Full implementation requires complex graph traversal ---
        // Placeholder for the logic described in the technical plan.
        // 1. Fetch recipe and ingredients.
        // 2. For each ingredient, get its cost (recursively if it's a sub-recipe).
        // 3. Sum costs and update the recipe's `totalCost`.
        // 4. Find parent recipes and trigger recalculation for them.
        // 5. Must handle circular references.
        print("Recalculating cost for recipe \(recipeId)...")
    }
    
    /// Checks for circular references when adding an ingredient to a recipe.
    /// - Throws: `RecipeServiceError.circularReference` if a cycle is detected.
    func checkForCircularReference(recipe: Recipe, newIngredient: Recipe) throws {
        // --- Placeholder Logic using DFS ---
        // This can be solved using a graph traversal algorithm like Depth First Search (DFS).
        // For now, we will just have the function signature.
        print("Checking for circular references...")
        // if cycle detected { throw RecipeServiceError.circularReference(...) }
    }
}
