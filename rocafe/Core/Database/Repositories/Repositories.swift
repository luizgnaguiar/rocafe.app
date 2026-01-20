import Foundation
import GRDB

// MARK: - Generic Repository Protocol
protocol Repository {
    associatedtype Model: FetchableRecord & PersistableRecord
    var dbQueue: DatabaseQueue { get }
    
    func getAll() -> [Model]
    func get(id: Int64) -> Model?
    func save(_ model: inout Model) throws
    func delete(id: Int64) -> Bool
}

extension Repository {
    var dbQueue: DatabaseQueue {
        return DatabaseManager.shared.dbQueue
    }
    
    func getAll() -> [Model] {
        try! dbQueue.read { db in
            try Model.fetchAll(db)
        }
    }
    
    func get(id: Int64) -> Model? {
        try! dbQueue.read { db in
            try Model.fetchOne(db, key: id)
        }
    }
    
    func save(_ model: inout Model) throws {
        try dbQueue.write { db in
            try model.save(db)
        }
    }
    
    func delete(id: Int64) -> Bool {
        try! dbQueue.write { db in
            try Model.deleteOne(db, key: id)
        }
    }
}

// MARK: - Specific Repository Protocols

protocol ProductRepository: Repository where Model == Product {
    // Add specific methods for Product if needed
}

protocol RecipeRepository: Repository where Model == Recipe {
    // Add specific methods for Recipe if needed
}

protocol CustomerRepository: Repository where Model == Customer {
    // Add specific methods for Customer if needed
}

protocol SupplierRepository: Repository where Model == Supplier {
    // Add specific methods for Supplier if needed
}

protocol DailyEntryRepository: Repository where Model == DailyEntry {
    // Add specific methods for DailyEntry if needed
}

protocol ExpenseRepository: Repository where Model == Expense {
    // Add specific methods for Expense if needed
}

protocol RecurringExpenseRepository: Repository where Model == RecurringExpense {
    // Add specific methods for RecurringExpense if needed
}

// MARK: - Concrete Implementations

class ProductRepositoryImpl: ProductRepository {}
class RecipeRepositoryImpl: RecipeRepository {}
class CustomerRepositoryImpl: CustomerRepository {}
class SupplierRepositoryImpl: SupplierRepository {}
class DailyEntryRepositoryImpl: DailyEntryRepository {}
class ExpenseRepositoryImpl: ExpenseRepository {}
class RecurringExpenseRepositoryImpl: RecurringExpenseRepository {}
