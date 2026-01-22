import Foundation
import GRDB

@MainActor
class SupplierService {
    private let repository: SupplierRepository

    init(repository: SupplierRepository = SupplierRepositoryImpl()) {
        self.repository = repository
    }

    func getAll() async throws -> [Supplier] {
        try await Task {
            try repository.getAll()
        }.value
    }

    func getById(_ id: Int64) async throws -> Supplier {
        guard let supplier = try await Task({ try repository.get(id: id) }).value else {
            throw SupplierServiceError.notFound
        }
        return supplier
    }

    func save(supplier: inout Supplier) async throws {
        if supplier.name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            throw SupplierServiceError.nameIsEmpty
        }
        var supplierToSave = supplier
        try await Task {
            try repository.save(&supplierToSave)
        }.value
        supplier = supplierToSave
    }

    func delete(supplier: Supplier) async throws {
        guard let supplierId = supplier.id else { return }
        let success = try await Task {
            do {
                return try repository.delete(id: supplierId)
            } catch let DatabaseError.foreignKeyViolation {
                throw SupplierServiceError.cannotDeleteWithProducts
            } catch {
                throw error
            }
        }.value
        
        if !success {
            throw SupplierServiceError.deleteFailed
        }
    }
}

enum SupplierServiceError: LocalizedError {
    case notFound
    case nameIsEmpty
    case cannotDeleteWithProducts
    case deleteFailed

    var errorDescription: String? {
        switch self {
        case .notFound:
            return "O fornecedor não foi encontrado."
        case .nameIsEmpty:
            return "O nome do fornecedor é obrigatório."
        case .cannotDeleteWithProducts:
            return "Este fornecedor não pode ser excluído pois existem produtos ou despesas associadas a ele."
        case .deleteFailed:
            return "Falha ao deletar o fornecedor."
        }
    }
}