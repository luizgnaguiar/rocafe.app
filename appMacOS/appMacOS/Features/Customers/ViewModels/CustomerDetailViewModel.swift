import Foundation
import Combine

 @MainActor
class CustomerDetailViewModel: ObservableObject, StandardViewModel {
    typealias DataType = Customer
    
    @Published var customer: Customer
    @Published var viewState: ViewState<Customer> = .idle
    
    private let service: CustomerService
    
    init(customer: Customer, service: CustomerService? = nil) {
        self.service = service ?? CustomerService()
        self.customer = customer
        self.viewState = .success(customer)
    }
    
    init(customerId: Int64, service: CustomerService? = nil) {
        self.service = service ?? CustomerService()
        self.customer = Customer(id: nil, name: "", isActive: true)
        Task {
            await fetchCustomer(withId: customerId)
        }
    }
    
    private func fetchCustomer(withId id: Int64) async {
        viewState = .loading
        do {
            let fetchedCustomer = try service.getById(id)
            self.customer = fetchedCustomer
            self.viewState = .success(fetchedCustomer)
        } catch {
            self.viewState = .error(error)
        }
    }
    
    func saveCustomer() async {
        viewState = .loading
        
        do {
            var customerToSave = self.customer
            try await service.save(customer: &customerToSave)
            self.customer = customerToSave
            viewState = .success(customerToSave)
        } catch {
            viewState = .error(error)
        }
    }
    
    func deleteCustomer() async {
        viewState = .loading
        
        do {
            try await service.delete(customer: self.customer)
            viewState = .success(self.customer)
        } catch {
            viewState = .error(error)
        }
    }
}