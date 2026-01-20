import Foundation
import GRDB

struct Customer: Codable, FetchableRecord, PersistableRecord, Identifiable {
    var id: Int64?
    var name: String
    var cpf: String?
    var phone: String?
    var email: String?
    var address: String?
    var city: String?
    var state: String?
    var zipCode: String?
    var notes: String?
    var isActive: Bool
    var createdAt: Date?
    var updatedAt: Date?
    
    static var databaseTableName = "customer"
}
