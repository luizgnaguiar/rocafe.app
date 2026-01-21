import Foundation
import GRDB

enum CustomerServiceError: Error, LocalizedError {
    case customerNotFound(id: Int64)
    case nameIsEmpty
    case emailInvalid
    case cannotDeleteWithPayments(Error)
    
    var errorDescription: String? {
        switch self {
        case .customerNotFound(let id):
            return "O cliente com ID \(id) não foi encontrado."
        case .nameIsEmpty:
            return "O nome do cliente é obrigatório."
        case .emailInvalid:
            return "O formato do e-mail é inválido."
        case .cannotDeleteWithPayments:
            return "Este cliente não pode ser excluído pois existem pagamentos associados a ele."
        }
    }
}

class CustomerService {
    
    private let repository: CustomerRepository
    
    init(repository: CustomerRepository = CustomerRepositoryImpl()) {
        self.repository = repository
    }
    
    func getAll() async throws -> [Customer] {
        return try await repository.getAll()
    }
    
    func getById(_ id: Int64) async throws -> Customer {
        guard let customer = try await repository.getById(id) else {
            throw CustomerServiceError.customerNotFound(id: id)
        }
        return customer
    }
    
    /// Saves a customer after validating its business rules.
    func save(customer: inout Customer) async throws {
        if customer.name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            throw CustomerServiceError.nameIsEmpty
        }
        
        // A simple email validation example.
        if let email = customer.email, !email.isEmpty, !isValidEmail(email) {
            throw CustomerServiceError.emailInvalid
        }
        
        try await repository.save(&customer)
    }
    
    /// Deletes a customer.
    /// Throws an error if the customer has associated payments, due to database constraints.
    func delete(customer: Customer) async throws {
        do {
            _ = try await repository.delete(customer)
        } catch let DatabaseError.foreignKeyViolation(message) {
            // This is where we catch the ON DELETE RESTRICT violation from SQLite
            throw CustomerServiceError.cannotDeleteWithPayments(DatabaseError.foreignKeyViolation(message))
        } catch {
            throw error
        }
    }
    
    private func isValidEmail(_ email: String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPred = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailPred.evaluate(with: email)
    }
}
