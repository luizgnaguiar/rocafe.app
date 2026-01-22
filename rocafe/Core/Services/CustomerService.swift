import Foundation
import GRDB

 @MainActor
class CustomerService {
    private let repository: CustomerRepository
    
    init(repository: CustomerRepository = CustomerRepositoryImpl()) {
        self.repository = repository
    }
    
    func getAll() async throws -> [Customer] {
        try await Task {
            try repository.getAll()
        }.value
    }
    
    func getById(_ id: Int64) throws -> Customer {
        guard let customer = try repository.getById(id) else {
            throw CustomerServiceError.notFound
        }
        return customer
    }
    
    func save(customer: inout Customer) async throws {
        try await Task {
            try repository.save(&customer)
        }.value
    }
    
    func delete(customer: Customer) async throws {
        let success = try await Task {
            try repository.delete(customer)
        }.value
        
        if !success {
            throw CustomerServiceError.deleteFailed
        }
    }
}

enum CustomerServiceError: LocalizedError {
    case notFound
    case deleteFailed
    
    var errorDescription: String? {
        switch self {
        case .notFound:
            return "Cliente não encontrado"
        case .deleteFailed:
            return "Falha ao deletar cliente"
        }
    }
}