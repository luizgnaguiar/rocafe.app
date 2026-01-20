import Foundation
import GRDB

struct Product: Codable, FetchableRecord, PersistableRecord, Identifiable {
    var id: Int64?
    var name: String
    var type: ProductType
    var category: ProductCategory? // Only for finished products
    
    // Pricing
    var purchasePrice: Decimal? // For rawMaterial or ready products
    var salePrice: Decimal?     // For ready products
    
    // Manufacturing
    var recipeId: Int64?        // For manufactured products
    var manufacturingCost: Decimal? // Cache for manufactured product cost
    
    // Supplier
    var supplierId: Int64?
    
    var isActive: Bool
    var createdAt: Date?
    var updatedAt: Date?

    static var databaseTableName = "product"
    
    static let supplier = belongsTo(Supplier.self)
    static let recipe = belongsTo(Recipe.self)
    
    var profitMargin: Decimal? {
        guard let salePrice = salePrice, salePrice > 0 else { return nil }
        
        let cost: Decimal
        if type == .rawMaterial || category == .ready {
            guard let purchasePrice = purchasePrice else { return nil }
            cost = purchasePrice
        } else if category == .manufactured {
            guard let manufacturingCost = manufacturingCost else { return nil }
            cost = manufacturingCost
        } else {
            return nil
        }
        
        guard cost > 0 else { return nil }
        
        return (salePrice - cost) / salePrice
    }
}
