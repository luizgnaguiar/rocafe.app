import Foundation
import Combine

@MainActor
class CustomerDetailViewModel: ObservableObject, StandardViewModel {
    typealias DataType = Customer
    
    @Published var customer: Customer
    @Published var viewState: ViewState<Customer> = .idle
    
    private let service: CustomerService
    
    init(customer: Customer, service: CustomerService = CustomerService()) {
        self.customer = customer
        self.service = service
        self.viewState = .success(customer)
    }
    
    init(customerId: Int64, service: CustomerService = CustomerService()) {
        self.customer = Customer(id: nil, name: "", isActive: true)
        self.service = service
        fetchCustomer(withId: customerId)
    }
    
    private func fetchCustomer(withId id: Int64) {
        viewState = .loading
        Task {
            do {
                let fetchedCustomer = try service.getById(id)
                self.customer = fetchedCustomer
                self.viewState = .success(fetchedCustomer)
            } catch {
                self.viewState = .error(error)
            }
        }
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
            do {.
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
