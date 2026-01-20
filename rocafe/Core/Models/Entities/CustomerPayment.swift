import Foundation
import GRDB

struct CustomerPayment: Codable, FetchableRecord, PersistableRecord, Identifiable {
    var id: Int64?
    var customerId: Int64
    var date: Date
    var amount: Decimal
    var paymentMethod: PaymentMethod
    var notes: String?
    var createdAt: Date?

    static var databaseTableName = "customerPayment"
    
    static let customer = belongsTo(Customer.self)
}
