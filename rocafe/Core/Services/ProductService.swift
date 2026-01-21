import Foundation
import GRDB

enum ProductServiceError: Error, LocalizedError {
    case productNotFound(id: Int64)
    case nameIsEmpty
    case invalidSalePrice
    case invalidSalePriceVsCost
    case cannotDeleteWhileInUse(Error)

    var errorDescription: String? {
        switch self {
        case .productNotFound(let id):
            return "O produto com ID \(id) não foi encontrado."
        case .nameIsEmpty:
            return "O nome do produto é obrigatório."
        case .invalidSalePrice:
            return "O preço de venda deve ser maior que zero."
        case .invalidSalePriceVsCost:
            return "O preço de venda não pode ser menor que o custo."
        case .cannotDeleteWhileInUse:
            return "Este produto não pode ser excluído pois está sendo usado em receitas ou registros diários."
        }
    }
}

class ProductService {

    private let repository: ProductRepository

    init(repository: ProductRepository = ProductRepositoryImpl()) {
        self.repository = repository
    }

    func getAll() async throws -> [Product] {
        try await repository.getAll()
    }

    func getById(_ id: Int64) async throws -> Product {
        guard let product = try await repository.get(id: id) else {
            throw ProductServiceError.productNotFound(id: id)
        }
        return product
    }

    func getRawMaterials() async throws -> [Product] {
        try await repository.dbPool.read { db in
            try Product.filter(Product.Columns.type == ProductType.rawMaterial.rawValue).fetchAll(db)
        }
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

        try await repository.save(&product)
    }

    func delete(product: Product) async throws {
        guard let productId = product.id else { return }
        do {
            _ = try await repository.delete(id: productId)
        } catch let DatabaseError.foreignKeyViolation(message) {
            throw ProductServiceError.cannotDeleteWhileInUse(DatabaseError.foreignKeyViolation(message))
        } catch {
            throw error
        }
    }
}
