import Foundation
import Combine

@MainActor
class CustomerDetailViewModel: ObservableObject {
    
    @Published var customer: Customer
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let repository: CustomerRepository
    
    init(customer: Customer?, repository: CustomerRepository = CustomerRepositoryImpl()) {
        self.customer = customer ?? Customer(id: nil, name: "", isActive: true)
        self.repository = repository
    }
    
    func saveCustomer() {
        guard validate() else { return }
        
        isLoading = true
        errorMessage = nil
        
        do {
            var customerToSave = self.customer
            try repository.save(&customerToSave)
            self.customer = customerToSave
        } catch {
            errorMessage = "Falha ao salvar o cliente: \(error.localizedDescription)"
        }
        
        isLoading = false
    }
    
    private func validate() -> Bool {
        if customer.name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            errorMessage = "O nome do cliente é obrigatório."
            return false
        }
        
        // TODO: Add CPF validation if needed
        
        errorMessage = nil
        return true
    }
}
