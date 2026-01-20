import Foundation
import Combine

@MainActor
class CustomerDetailViewModel: ObservableObject {
    
    @Published var customer: Customer
    @Published var viewState: ViewState<Customer> = .idle
    
    private let service: CustomerService
    
    init(customer: Customer?, service: CustomerService = CustomerService()) {
        self.customer = customer ?? Customer(id: nil, name: "", isActive: true)
        self.service = service
    }
    
    func saveCustomer() {
        viewState = .loading
        
        Task {
            do {
                var customerToSave = self.customer
                try service.save(customer: &customerToSave)
                self.customer = customerToSave
                viewState = .success(customerToSave)
            } catch {
                viewState = .error(error)
            }
        }
    }
    
    func deleteCustomer() {
        viewState = .loading
        
        Task {
            do {
                try service.delete(customer: self.customer)
                // On success, we can't show the deleted customer,
                // so we pass a copy to the success state for any listening view.
                viewState = .success(self.customer)
            } catch {
                viewState = .error(error)
            }
        }
    }
}
