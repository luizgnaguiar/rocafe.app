import Foundation
import GRDB

// MARK: - Generic Repository Protocol
protocol Repository {
    associatedtype Model: FetchableRecord & PersistableRecord
    var dbPool: DatabasePool { get }
    
    func getAll() async throws -> [Model]
    func get(id: Int64) async throws -> Model?
    func save(_ model: inout Model) async throws
    func delete(id: Int64) async throws -> Bool
}

extension Repository {
    var dbPool: DatabasePool {
        return DatabaseManager.shared.dbPool
    }
    
    func getAll() async throws -> [Model] {
        try await dbPool.read { db in
            try Model.fetchAll(db)
        }
    }
    
    func get(id: Int64) async throws -> Model? {
        try await dbPool.read { db in
            try Model.fetchOne(db, key: id)
        }
    }
    
    func save(_ model: inout Model) async throws {
        try await dbPool.write { db in
            try model.save(db)
        }
    }
    
    func delete(id: Int64) async throws -> Bool {
        try await dbPool.write { db in
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
    func getByRecipeId(recipeId: Int64) async throws -> [RecipeIngredient]
}

// MARK: - Custom Repository Protocols
// For entities that need more specific methods than the generic ones

protocol CustomerRepository {
//... (rest of the file is unchanged) ...
// MARK: - Concrete Implementations
//... (rest of the file is unchanged) ...
class RecurringExpenseRepositoryImpl: BaseRepositoryImpl<RecurringExpense>, RecurringExpenseRepository {}
class RecipeIngredientRepositoryImpl: BaseRepositoryImpl<RecipeIngredient>, RecipeIngredientRepository {
    func getByRecipeId(recipeId: Int64) async throws -> [RecipeIngredient] {
        try await dbPool.read { db in
            try RecipeIngredient
                .filter(RecipeIngredient.Columns.recipeId == recipeId)
                .fetchAll(db)
        }
    }
}


class CustomerRepositoryImpl: CustomerRepository {
//... (rest of the file is unchanged) ...

    private var dbPool: DatabasePool

    init(dbPool: DatabasePool = DatabaseManager.shared.dbPool) {
        self.dbPool = dbPool
    }

    func getAll() async throws -> [Customer] {
        try await dbPool.read { db in
            try Customer.fetchAll(db)
        }
    }

    func getById(_ id: Int64) async throws -> Customer? {
        try await dbPool.read { db in
            try Customer.fetchOne(db, key: id)
        }
    }

    func save(_ customer: inout Customer) async throws {
        try await dbPool.write { db in
            try customer.save(db)
        }
    }

    func delete(_ customer: Customer) async throws -> Bool {
        try await dbPool.write { db in
            try customer.delete(db)
        }
    }
}
