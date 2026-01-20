import Foundation
import GRDB

struct DailyEntry: Codable, FetchableRecord, PersistableRecord, Identifiable {
    var id: Int64?
    var date: Date
    
    // Vendas do Dia
    var salesCash: Decimal
    var salesCredit: Decimal
    var salesDebit: Decimal
    var salesPix: Decimal
    
    // Contas Recebidas
    var receivedCash: Decimal
    var receivedCredit: Decimal
    var receivedDebit: Decimal
    var receivedPix: Decimal
    
    var createdAt: Date?
    var updatedAt: Date?
    
    static var databaseTableName = "dailyEntry"
    
    static func new() -> DailyEntry {
        DailyEntry(
            id: nil,
            date: Date(),
            salesCash: 0, salesCredit: 0, salesDebit: 0, salesPix: 0,
            receivedCash: 0, receivedCredit: 0, receivedDebit: 0, receivedPix: 0,
            createdAt: Date(),
            updatedAt: Date()
        )
    }
}
