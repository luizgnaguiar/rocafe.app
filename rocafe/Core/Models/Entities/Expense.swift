import Foundation
import GRDB

struct Expense: Codable, FetchableRecord, PersistableRecord, Identifiable {
    var id: Int64?
    var recurringExpenseId: Int64?
    var description: String
    var category: ExpenseCategory
    var amount: Decimal
    var dueDate: Date
    var paymentDate: Date?
    var isPaid: Bool
    var wasAdjusted: Bool
    var supplierId: Int64?
    var notes: String?
    var createdAt: Date?
    var updatedAt: Date?

    static var databaseTableName = "expense"
    
    static let supplier = belongsTo(Supplier.self)
    static let recurringExpense = belongsTo(RecurringExpense.self)
}
