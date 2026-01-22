import Foundation
import GRDB

struct Supplier: Codable, FetchableRecord, PersistableRecord, Identifiable {
    var id: Int64?
    var name: String
    var legalName: String?
    var cnpj: String?
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

    static var databaseTableName = "supplier"
}

extension Supplier {
    enum Columns: String, ColumnExpression {
        case id
        case name
        case legalName
        case cnpj
        case phone
        case email
        case address
        case city
        case state
        case zipCode
        case notes
        case isActive
        case createdAt
        case updatedAt
    }
}
