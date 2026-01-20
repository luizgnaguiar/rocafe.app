import Foundation
import GRDB

struct RecipeIngredient: Codable, FetchableRecord, PersistableRecord, Identifiable {
    var id: Int64?
    var recipeId: Int64
    var ingredientType: IngredientType
    var ingredientProductId: Int64? // FK to Product if rawMaterial
    var ingredientRecipeId: Int64?  // FK to Recipe if subRecipe
    var quantity: Decimal

    static var databaseTableName = "recipeIngredient"
    
    static let recipe = belongsTo(Recipe.self)
    
    // Association to the product (as a raw material)
    var rawMaterial: BelongsToAssociation<Product> {
        return belongsTo(Product.self, key: "ingredientProductId")
    }
    
    // Association to another recipe (as a sub-recipe)
    var subRecipe: BelongsToAssociation<Recipe> {
        return belongsTo(Recipe.self, key: "ingredientRecipeId")
    }
}
