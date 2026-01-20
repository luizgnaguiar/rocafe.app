import Foundation
import GRDB

struct Recipe: Codable, FetchableRecord, PersistableRecord, Identifiable {
    var id: Int64?
    var productId: Int64
    var name: String
    var version: Int
    var totalCost: Decimal
    var isActive: Bool
    var createdAt: Date?
    var updatedAt: Date?

    static var databaseTableName = "recipe"
    
    static let product = belongsTo(Product.self)
    static let ingredients = hasMany(RecipeIngredient.self)
    static let versions = hasMany(RecipeVersion.self)
}
