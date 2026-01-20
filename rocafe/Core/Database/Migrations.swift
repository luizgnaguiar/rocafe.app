import Foundation
import GRDB

struct AppMigrations {
    
    static func register(migrator: inout DatabaseMigrator) {
        
        // V1: Initial Schema
        migrator.registerMigration("v1.0.0") { db in
            
            // DailyEntry Table
            try db.create(table: DailyEntry.databaseTableName) { t in
                t.autoIncrementedPrimaryKey("id")
                t.column("date", .datetime).notNull()
                t.column("salesCash", .decimal).notNull()
                t.column("salesCredit", .decimal).notNull()
                t.column("salesDebit", .decimal).notNull()
                t.column("salesPix", .decimal).notNull()
                t.column("receivedCash", .decimal).notNull()
                t.column("receivedCredit", .decimal).notNull()
                t.column("receivedDebit", .decimal).notNull()
                t.column("receivedPix", .decimal).notNull()
                t.column("createdAt", .datetime).defaults(to: Date())
                t.column("updatedAt", .datetime).defaults(to: Date())
            }
            
            // Supplier Table
            try db.create(table: Supplier.databaseTableName) { t in
                t.autoIncrementedPrimaryKey("id")
                t.column("name", .text).notNull().collate(.localizedCaseInsensitive)
                t.column("legalName", .text)
                t.column("cnpj", .text).unique()
                t.column("phone", .text)
                t.column("email", .text)
                t.column("address", .text)
                t.column("city", .text)
                t.column("state", .text)
                t.column("zipCode", .text)
                t.column("notes", .text)
                t.column("isActive", .boolean).notNull().defaults(to: true)
                t.column("createdAt", .datetime).defaults(to: Date())
                t.column("updatedAt", .datetime).defaults(to: Date())
            }
            
            // Customer Table
            try db.create(table: Customer.databaseTableName) { t in
                t.autoIncrementedPrimaryKey("id")
                t.column("name", .text).notNull().collate(.localizedCaseInsensitive)
                t.column("cpf", .text).unique()
                t.column("phone", .text)
                t.column("email", .text)
                t.column("address", .text)
                t.column("city", .text)
                t.column("state", .text)
                t.column("zipCode", .text)
                t.column("notes", .text)
                t.column("isActive", .boolean).notNull().defaults(to: true)
                t.column("createdAt", .datetime).defaults(to: Date())
                t.column("updatedAt", .datetime).defaults(to: Date())
            }
            
            // CustomerPayment Table
            try db.create(table: CustomerPayment.databaseTableName) { t in
                t.autoIncrementedPrimaryKey("id")
                t.column("customerId", .integer).notNull().references(Customer.databaseTableName, onDelete: .cascade)
                t.column("date", .datetime).notNull()
                t.column("amount", .decimal).notNull()
                t.column("paymentMethod", .text).notNull()
                t.column("notes", .text)
                t.column("createdAt", .datetime).defaults(to: Date())
            }
            
            // RecurringExpense Table
            try db.create(table: RecurringExpense.databaseTableName) { t in
                t.autoIncrementedPrimaryKey("id")
                t.column("description", .text).notNull()
                t.column("category", .text).notNull()
                t.column("baseAmount", .decimal).notNull()
                t.column("dayOfMonth", .integer).notNull()
                t.column("startDate", .datetime).notNull()
                t.column("endDate", .datetime)
                t.column("isActive", .boolean).notNull().defaults(to: true)
                t.column("supplierId", .integer).references(Supplier.databaseTableName, onDelete: .setNull)
                t.column("createdAt", .datetime).defaults(to: Date())
                t.column("updatedAt", .datetime).defaults(to: Date())
            }
            
            // Expense Table
            try db.create(table: Expense.databaseTableName) { t in
                t.autoIncrementedPrimaryKey("id")
                t.column("recurringExpenseId", .integer).references(RecurringExpense.databaseTableName, onDelete: .setNull)
                t.column("description", .text).notNull()
                t.column("category", .text).notNull()
                t.column("amount", .decimal).notNull()
                t.column("dueDate", .datetime).notNull()
                t.column("paymentDate", .datetime)
                t.column("isPaid", .boolean).notNull().defaults(to: false)
                t.column("wasAdjusted", .boolean).notNull().defaults(to: false)
                t.column("supplierId", .integer).references(Supplier.databaseTableName, onDelete: .setNull)
                t.column("notes", .text)
                t.column("createdAt", .datetime).defaults(to: Date())
                t.column("updatedAt", .datetime).defaults(to: Date())
            }
            
            // Recipe Table
            try db.create(table: Recipe.databaseTableName) { t in
                t.autoIncrementedPrimaryKey("id")
                t.column("productId", .integer).notNull() // This will be a FK after product table is created
                t.column("name", .text).notNull()
                t.column("version", .integer).notNull().defaults(to: 1)
                t.column("totalCost", .decimal).notNull().defaults(to: 0)
                t.column("isActive", .boolean).notNull().defaults(to: true)
                t.column("createdAt", .datetime).defaults(to: Date())
                t.column("updatedAt", .datetime).defaults(to: Date())
            }
            
            // Product Table
            try db.create(table: Product.databaseTableName) { t in
                t.autoIncrementedPrimaryKey("id")
                t.column("name", .text).notNull().unique().collate(.localizedCaseInsensitive)
                t.column("type", .text).notNull()
                t.column("category", .text)
                t.column("purchasePrice", .decimal)
                t.column("salePrice", .decimal)
                t.column("recipeId", .integer).references(Recipe.databaseTableName, onDelete: .setNull)
                t.column("manufacturingCost", .decimal)
                t.column("supplierId", .integer).references(Supplier.databaseTableName, onDelete: .setNull)
                t.column("isActive", .boolean).notNull().defaults(to: true)
                t.column("createdAt", .datetime).defaults(to: Date())
                t.column("updatedAt", .datetime).defaults(to: Date())
            }
            
            // Now add the foreign key constraint to Recipe
            try db.alter(table: Recipe.databaseTableName) { t in
                t.add(foreignKey: ["productId"], references: Product.databaseTableName, onDelete: .cascade)
            }
            
            // RecipeIngredient Table
            try db.create(table: RecipeIngredient.databaseTableName) { t in
                t.autoIncrementedPrimaryKey("id")
                t.column("recipeId", .integer).notNull().references(Recipe.databaseTableName, onDelete: .cascade)
                t.column("ingredientType", .text).notNull()
                t.column("ingredientProductId", .integer).references(Product.databaseTableName, onDelete: .cascade)
                t.column("ingredientRecipeId", .integer).references(Recipe.databaseTableName, onDelete: .cascade)
                t.column("quantity", .decimal).notNull()
                
                // Ensure that either product or recipe ID is set, but not both
                t.check(sql: "(ingredientProductId IS NOT NULL AND ingredientRecipeId IS NULL) OR (ingredientProductId IS NULL AND ingredientRecipeId IS NOT NULL)")
            }
            
            // RecipeVersion Table
            try db.create(table: RecipeVersion.databaseTableName) { t in
                t.autoIncrementedPrimaryKey("id")
                t.column("recipeId", .integer).notNull().references(Recipe.databaseTableName, onDelete: .cascade)
                t.column("version", .integer).notNull()
                t.column("previousData", .text).notNull() // JSON blob
                t.column("changeDescription", .text).notNull()
                t.column("modifiedAt", .datetime).notNull()
            }
        }
    }
}
