import Foundation
import GRDB

struct RecipeVersion: Codable, FetchableRecord, PersistableRecord, Identifiable {
    var id: Int64?
    var recipeId: Int64
    var version: Int
    var previousData: String // JSON snapshot of the recipe and its ingredients
    var changeDescription: String
    var modifiedAt: Date

    static var databaseTableName = "recipeVersion"
    
    static let recipe = belongsTo(Recipe.self)
}
