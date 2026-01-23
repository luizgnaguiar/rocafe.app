import Foundation

enum ExpenseCategory: String, Codable, CaseIterable, Identifiable {
    case pessoal = "Pessoal/Folha de Pagamento"
    case aluguel = "Aluguel e Instalações"
    case contas = "Contas de Consumo"
    case marketing = "Marketing e Vendas"
    case materiais = "Materiais e Suprimentos"
    case servicos = "Serviços Terceirizados"
    case tecnologia = "Tecnologia"
    case financeiras = "Despesas Bancárias e Financeiras"
    case viagens = "Viagens e Representação"
    case impostos = "Impostos e Taxas"

    var id: String { self.rawValue }
}
