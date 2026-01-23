import Foundation
import GRDB

@MainActor
class ProductService {
    private let repository: ProductRepository

    init(repository: ProductRepository = ProductRepositoryImpl()) {
        self.repository = repository
    }

    func getAll() async throws -> [Product] {
        try await Task {
            try repository.getAll()
        }.value
    }

    func getById(_ id: Int64) async throws -> Product {
        guard let product = try await Task({ try repository.get(id: id) }).value else {
            throw ProductServiceError.notFound
        }
        return product
    }

    func getRawMaterials() async throws -> [Product] {
        try await Task {
            try repository.dbPool.read { db in
                try Product.filter(Product.Columns.type == ProductType.rawMaterial.rawValue).fetchAll(db)
            }
        }.value
    }

    func save(product: inout Product) async throws {
        // Basic validation
        if product.name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            throw ProductServiceError.nameIsEmpty
        }
        if let salePrice = product.salePrice {
            if salePrice <= 0 {
                throw ProductServiceError.invalidSalePrice
            }
            let cost = product.purchasePrice ?? product.manufacturingCost ?? 0
            if salePrice < cost {
                throw ProductServiceError.invalidSalePriceVsCost
            }
        }
        
        // Adjust data based on type
        if product.type == .rawMaterial {
            product.category = nil
            product.salePrice = nil
        }

        var productToSave = product
        try await Task {
            try repository.save(&productToSave)
        }.value
        product = productToSave
    }

    func delete(product: Product) async throws {
        guard let productId = product.id else { return }
        let success = try await Task {
            do {
                return try repository.delete(id: productId)
            } catch let DatabaseError.foreignKeyViolation {
                throw ProductServiceError.cannotDeleteWhileInUse
            } catch {
                throw error
            }
        }.value
        
        if !success {
            throw ProductServiceError.deleteFailed
        }
    }
}


enum ProductServiceError: LocalizedError {
    case notFound
    case nameIsEmpty
    case invalidSalePrice
    case invalidSalePriceVsCost
    case cannotDeleteWhileInUse
    case deleteFailed

    var errorDescription: String? {
        switch self {
        case .notFound:
            return "O produto não foi encontrado."
        case .nameIsEmpty:
            return "O nome do produto é obrigatório."
        case .invalidSalePrice:
            return "O preço de venda deve ser maior que zero."
        case .invalidSalePriceVsCost:
            return "O preço de venda não pode ser menor que o custo."
        case .cannotDeleteWhileInUse:
            return "Este produto não pode ser excluído pois está sendo usado em receitas ou registros diários."
        case .deleteFailed:
            return "Falha ao deletar o produto."
        }
    }
}