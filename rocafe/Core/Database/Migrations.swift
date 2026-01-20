import Foundation
import GRDB

struct AppMigrations {
    
    static func register(migrator: inout DatabaseMigrator) {
        
        // NOTE: This initial migration has been corrected and hardened during the transition
        // from an architectural prototype to a production-ready application.
        // The changes ensure data integrity, referential consistency, and query performance.
        // Key changes include:
        // - Reordering table creation to avoid unnecessary ALTER TABLE statements.
        // - Enforcing ON DELETE RESTRICT on critical foreign keys to prevent data loss.
        // - Adding CHECK constraints for non-negative financial values.
        // - Creating explicit indexes on all foreign keys and common query columns.
        
        migrator.registerMigration("v1.0.0-hardened") { db in
            
            // Supplier Table
            try db.create(table: Supplier.databaseTableName) { t in
                t.autoIncrementedPrimaryKey("id")
                t.column("name", .text).notNull().collate(.localizedCaseInsensitive)
                t.column("legalName", .text)
                t.column("cnpj", .text).unique()
                t.column("phone", .text)
                t.column("email", .text).unique()
                t.column("address", .text)
                t.column("city", .text)
                t.column("state", .text)
                t.column("zipCode", .text)
                t.column("notes", .text)
                t.column("isActive", .boolean).notNull().defaults(to: true)
                t.column("createdAt", .datetime).notNull().defaults(to: Date())
                t.column("updatedAt", .datetime).notNull().defaults(to: Date())
            }
            try db.create(index: "index_supplier_on_name", on: Supplier.databaseTableName, columns: ["name"])

            // Customer Table
            try db.create(table: Customer.databaseTableName) { t in
                t.autoIncrementedPrimaryKey("id")
                t.column("name", .text).notNull().collate(.localizedCaseInsensitive)
                t.column("cpf", .text).unique()
                t.column("phone", .text)
                t.column("email", .text).unique()
                t.column("address", .text)
                t.column("city", .text)
                t.column("state", .text)
                t.column("zipCode", .text)
                t.column("notes", .text)
                t.column("isActive", .boolean).notNull().defaults(to: true)
                t.column("createdAt", .datetime).notNull().defaults(to: Date())
                t.column("updatedAt", .datetime).notNull().defaults(to: Date())
            }
            try db.create(index: "index_customer_on_name", on: Customer.databaseTableName, columns: ["name"])
            
            // Product Table
            try db.create(table: Product.databaseTableName) { t in
                t.autoIncrementedPrimaryKey("id")
                t.column("name", .text).notNull().unique().collate(.localizedCaseInsensitive)
                t.column("type", .text).notNull()
                t.column("category", .text)
                t.column("purchasePrice", .decimal).check { $0 >= 0 }
                t.column("salePrice", .decimal).check { $0 >= 0 }
                t.column("manufacturingCost", .decimal).check { $0 >= 0 }
                t.column("supplierId", .integer).references(Supplier.databaseTableName, onDelete: .restrict)
                t.column("isActive", .boolean).notNull().defaults(to: true)
                t.column("createdAt", .datetime).notNull().defaults(to: Date())
                t.column("updatedAt", .datetime).notNull().defaults(to: Date())
            }
            try db.create(index: "index_product_on_supplierId", on: Product.databaseTableName, columns: ["supplierId"])

            // Recipe Table
            try db.create(table: Recipe.databaseTableName) { t in
                t.autoIncrementedPrimaryKey("id")
                t.column("productId", .integer).notNull().unique().references(Product.databaseTableName, onDelete: .cascade) // A recipe is intrinsically linked to a single product. If product is removed, recipe is useless.
                t.column("name", .text).notNull()
                t.column("version", .integer).notNull().defaults(to: 1)
                t.column("totalCost", .decimal).notNull().defaults(to: 0).check { $0 >= 0 }
                t.column("isActive", .boolean).notNull().defaults(to: true)
                t.column("createdAt", .datetime).notNull().defaults(to: Date())
                t.column("updatedAt", .datetime).notNull().defaults(to: Date())
            }
            try db.create(index: "index_recipe_on_productId", on: Recipe.databaseTableName, columns: ["productId"])


            // RecipeIngredient Table
            try db.create(table: RecipeIngredient.databaseTableName) { t in
                t.autoIncrementedPrimaryKey("id")
                t.column("recipeId", .integer).notNull().references(Recipe.databaseTableName, onDelete: .cascade) // Ingredients are part of a recipe.
                t.column("ingredientType", .text).notNull()
                t.column("ingredientProductId", .integer).references(Product.databaseTableName, onDelete: .restrict)
                t.column("ingredientRecipeId", .integer).references(Recipe.databaseTableName, onDelete: .restrict)
                t.column("quantity", .decimal).notNull().check { $0 > 0 }
                
                t.check(sql: "(ingredientProductId IS NOT NULL AND ingredientRecipeId IS NULL) OR (ingredientProductId IS NULL AND ingredientRecipeId IS NOT NULL)")
            }
            try db.create(index: "index_recipeIngredient_on_recipeId", on: RecipeIngredient.databaseTableName, columns: ["recipeId"])
            try db.create(index: "index_recipeIngredient_on_ingredientProductId", on: RecipeIngredient.databaseTableName, columns: ["ingredientProductId"])
            try db.create(index: "index_recipeIngredient_on_ingredientRecipeId", on: RecipeIngredient.databaseTableName, columns: ["ingredientRecipeId"])


            // RecipeVersion Table
            try db.create(table: RecipeVersion.databaseTableName) { t in
                t.autoIncrementedPrimaryKey("id")
                t.column("recipeId", .integer).notNull().references(Recipe.databaseTableName, onDelete: .cascade) // Versions are part of a recipe.
                t.column("version", .integer).notNull()
                t.column("previousData", .text).notNull() // JSON blob
                t.column("changeDescription", .text).notNull()
                t.column("modifiedAt", .datetime).notNull()
            }
            try db.create(index: "index_recipeVersion_on_recipeId", on: RecipeVersion.databaseTableName, columns: ["recipeId"])
            
            // RecurringExpense Table
            try db.create(table: RecurringExpense.databaseTableName) { t in
                t.autoIncrementedPrimaryKey("id")
                t.column("description", .text).notNull()
                t.column("category", .text).notNull()
                t.column("baseAmount", .decimal).notNull().check { $0 >= 0 }
                t.column("dayOfMonth", .integer).notNull().check { $0 >= 1 AND $0 <= 31 }
                t.column("startDate", .datetime).notNull()
                t.column("endDate", .datetime)
                t.column("isActive", .boolean).notNull().defaults(to: true)
                t.column("supplierId", .integer).references(Supplier.databaseTableName, onDelete: .restrict)
                t.column("createdAt", .datetime).notNull().defaults(to: Date())
                t.column("updatedAt", .datetime).notNull().defaults(to: Date())
            }
            try db.create(index: "index_recurringExpense_on_supplierId", on: RecurringExpense.databaseTableName, columns: ["supplierId"])

            // Expense Table
            try db.create(table: Expense.databaseTableName) { t in
                t.autoIncrementedPrimaryKey("id")
                t.column("recurringExpenseId", .integer).references(RecurringExpense.databaseTableName, onDelete: .setNull)
                t.column("description", .text).notNull()
                t.column("category", .text).notNull()
                t.column("amount", .decimal).notNull().check { $0 >= 0 }
                t.column("dueDate", .datetime).notNull()
                t.column("paymentDate", .datetime)
                t.column("isPaid", .boolean).notNull().defaults(to: false)
                t.column("wasAdjusted", .boolean).notNull().defaults(to: false)
                t.column("supplierId", .integer).references(Supplier.databaseTableName, onDelete: .restrict)
                t.column("notes", .text)
                t.column("createdAt", .datetime).notNull().defaults(to: Date())
                t.column("updatedAt", .datetime).notNull().defaults(to: Date())
            }
            try db.create(index: "index_expense_on_recurringExpenseId", on: Expense.databaseTableName, columns: ["recurringExpenseId"])
            try db.create(index: "index_expense_on_supplierId", on: Expense.databaseTableName, columns: ["supplierId"])
            try db.create(index: "index_expense_on_dueDate", on: Expense.databaseTableName, columns: ["dueDate"])

            // CustomerPayment Table
            try db.create(table: CustomerPayment.databaseTableName) { t in
                t.autoIncrementedPrimaryKey("id")
                t.column("customerId", .integer).notNull().references(Customer.databaseTableName, onDelete: .restrict)
                t.column("date", .datetime).notNull()
                t.column("amount", .decimal).notNull().check { $0 > 0 }
                t.column("paymentMethod", .text).notNull()
                t.column("notes", .text)
                t.column("createdAt", .datetime).notNull().defaults(to: Date())
            }
            try db.create(index: "index_customerPayment_on_customerId", on: CustomerPayment.databaseTableName, columns: ["customerId"])
            
            // DailyEntry Table
            try db.create(table: DailyEntry.databaseTableName) { t in
                t.autoIncrementedPrimaryKey("id")
                t.column("date", .datetime).notNull().unique()
                t.column("salesCash", .decimal).notNull().defaults(to: 0).check { $0 >= 0 }
                t.column("salesCredit", .decimal).notNull().defaults(to: 0).check { $0 >= 0 }
                t.column("salesDebit", .decimal).notNull().defaults(to: 0).check { $0 >= 0 }
                t.column("salesPix", .decimal).notNull().defaults(to: 0).check { $0 >= 0 }
                t.column("receivedCash", .decimal).notNull().defaults(to: 0).check { $0 >= 0 }
                t.column("receivedCredit", .decimal).notNull().defaults(to: 0).check { $0 >= 0 }
                t.column("receivedDebit", .decimal).notNull().defaults(to: 0).check { $0 >= 0 }
                t.column("receivedPix", .decimal).notNull().defaults(to: 0).check { $0 >= 0 }
                t.column("createdAt", .datetime).notNull().defaults(to: Date())
                t.column("updatedAt", .datetime).notNull().defaults(to: Date())
            }
            try db.create(index: "index_dailyEntry_on_date", on: DailyEntry.databaseTableName, columns: ["date"])
        }
    }
}
