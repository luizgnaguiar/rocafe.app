import Foundation
import GRDB

struct RecurringExpense: Codable, FetchableRecord, PersistableRecord, Identifiable {
    var id: Int64?
    var description: String
    var category: ExpenseCategory
    var baseAmount: Decimal
    var dayOfMonth: Int
    var startDate: Date
    var endDate: Date?
    var isActive: Bool
    var supplierId: Int64?
    var createdAt: Date?
    var updatedAt: Date?

    static var databaseTableName = "recurringExpense"
    
    static let supplier = belongsTo(Supplier.self)
    static let expenses = hasMany(Expense.self)
}

extension RecurringExpense {
    enum Columns: String, ColumnExpression {
        case id
        case description
        case category
        case baseAmount
        case dayOfMonth
        case startDate
        case endDate
        case isActive
        case supplierId
        case createdAt
        case updatedAt
    }
}
