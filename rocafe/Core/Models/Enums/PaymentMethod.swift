import Foundation

enum PaymentMethod: String, Codable, CaseIterable {
    case cash = "Dinheiro"
    case credit = "Crédito"
    case debit = "Débito"
    case pix = "PIX"
}
