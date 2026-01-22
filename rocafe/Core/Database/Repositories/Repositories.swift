import Foundation
import GRDB

// MARK: - Generic Repository Protocol
protocol Repository {
    associatedtype Model: FetchableRecord & PersistableRecord
    var dbPool: DatabasePool { get }
    
    func getAll() throws -> [Model]
    func get(id: Int64) throws -> Model?
    func save(_ model: inout Model) throws
    func delete(id: Int64) throws -> Bool
}

// MARK: - Base Repository Implementation
class BaseRepositoryImpl<Model: FetchableRecord & PersistableRecord>: Repository {
    let dbPool: DatabasePool
    
    init(dbPool: DatabasePool = DatabaseManager.shared.dbPool) {
        self.dbPool = dbPool
    }
    
    func getAll() throws -> [Model] {
        try dbPool.read { db in
            try Model.fetchAll(db)
        }
    }
    
    func get(id: Int64) throws -> Model? {
        try dbPool.read { db in
            try Model.fetchOne(db, key: id)
        }
    }
    
    func save(_ model: inout Model) throws {
        try dbPool.write { db in
            try model.save(db)
        }
    }
    
    func delete(id: Int64) throws -> Bool {
        try dbPool.write { db in
            try Model.deleteOne(db, key: id)
        }
    }
}

// MARK: - Specific Repository Protocols
protocol ProductRepository: Repository where Model == Product {}
protocol RecipeRepository: Repository where Model == Recipe {}
protocol SupplierRepository: Repository where Model == Supplier {}
protocol DailyEntryRepository: Repository where Model == DailyEntry {}
protocol ExpenseRepository: Repository where Model == Expense {}
protocol RecurringExpenseRepository: Repository where Model == RecurringExpense {}

protocol RecipeIngredientRepository: Repository where Model == RecipeIngredient {
    func getByRecipeId(recipeId: Int64) throws -> [RecipeIngredient]
}

protocol CustomerRepository {
    func getAll() throws -> [Customer]
    func getById(_ id: Int64) throws -> Customer?
    func save(_ customer: inout Customer) throws
    func delete(_ customer: Customer) throws -> Bool
}

// MARK: - Concrete Implementations
class ProductRepositoryImpl: BaseRepositoryImpl<Product>, ProductRepository {}
class RecipeRepositoryImpl: BaseRepositoryImpl<Recipe>, RecipeRepository {}
class SupplierRepositoryImpl: BaseRepositoryImpl<Supplier>, SupplierRepository {}
class DailyEntryRepositoryImpl: BaseRepositoryImpl<DailyEntry>, DailyEntryRepository {}
class ExpenseRepositoryImpl: BaseRepositoryImpl<Expense>, ExpenseRepository {}
class RecurringExpenseRepositoryImpl: BaseRepositoryImpl<RecurringExpense>, RecurringExpenseRepository {}

class RecipeIngredientRepositoryImpl: BaseRepositoryImpl<RecipeIngredient>, RecipeIngredientRepository {
    func getByRecipeId(recipeId: Int64) throws -> [RecipeIngredient] {
        try dbPool.read { db in
            try RecipeIngredient
                .filter(RecipeIngredient.Columns.recipeId == recipeId)
                .fetchAll(db)
        }
    }
}

class CustomerRepositoryImpl: CustomerRepository {
    private let dbPool: DatabasePool

    init(dbPool: DatabasePool = DatabaseManager.shared.dbPool) {
        self.dbPool = dbPool
    }

    func getAll() throws -> [Customer] {
        try dbPool.read { db in
            try Customer.fetchAll(db)
        }
    }

    func getById(_ id: Int64) throws -> Customer? {
        try dbPool.read { db in
            try Customer.fetchOne(db, key: id)
        }
    }

    func save(_ customer: inout Customer) throws {
        try dbPool.write { db in
            try customer.save(db)
        }
    }

    func delete(_ customer: Customer) throws -> Bool {
        try dbPool.write { db in
            try customer.delete(db)
        }
    }
}