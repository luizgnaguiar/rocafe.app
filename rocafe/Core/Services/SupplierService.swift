import Foundation
import GRDB

enum SupplierServiceError: Error, LocalizedError {
    case supplierNotFound(id: Int64)
    case nameIsEmpty
    case cannotDeleteWithProducts(Error)

    var errorDescription: String? {
        switch self {
        case .supplierNotFound(let id):
            return "O fornecedor com ID \(id) não foi encontrado."
        case .nameIsEmpty:
            return "O nome do fornecedor é obrigatório."
        case .cannotDeleteWithProducts:
            return "Este fornecedor não pode ser excluído pois existem produtos associados a ele."
        }
    }
}

class SupplierService {

    private let repository: SupplierRepository

    init(repository: SupplierRepository = SupplierRepositoryImpl()) {
        self.repository = repository
    }

    func getAll() -> [Supplier] {
        return repository.getAll()
    }

    func getById(_ id: Int64) throws -> Supplier {
        guard let supplier = repository.get(id: id) else {
            throw SupplierServiceError.supplierNotFound(id: id)
        }
        return supplier
    }

    func save(supplier: inout Supplier) throws {
        if supplier.name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            throw SupplierServiceError.nameIsEmpty
        }
        try repository.save(&supplier)
    }

    func delete(supplier: Supplier) throws {
        do {
            _ = try repository.delete(id: supplier.id!)
        } catch let DatabaseError.foreignKeyViolation(message) {
            throw SupplierServiceError.cannotDeleteWithProducts(DatabaseError.foreignKeyViolation(message))
        } catch {
            throw error
        }
    }
}
