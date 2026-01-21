import Foundation
import Combine

@MainActor
class CustomerListViewModel: ObservableObject, StandardViewModel {
    typealias DataType = [Customer]
    
    @Published var viewState: ViewState<[Customer]> = .idle
    @Published var searchText: String = ""
    
    private let customerService: CustomerService
    private var allCustomers: [Customer] = []
    
    var filteredCustomers: [Customer] {
        guard case .success(let customers) = viewState else { return [] }
        
        if searchText.isEmpty {
            return customers
        }
        return customers.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
    }
    
    init(customerService: CustomerService = CustomerService()) {
        self.customerService = customerService
    }
    
    func fetchCustomers() async {
        viewState = .loading
        
        do {
            let customers = try await customerService.getAll()
            
            if customers.isEmpty {
                viewState = .empty
            } else {
                // Keep a separate copy for filtering if needed, and update the viewState
                allCustomers = customers
                viewState = .success(customers)
            }
        } catch {
            viewState = .error(error)
        }
    }
    
    func deleteCustomer(at offsets: IndexSet) {
        Task {
            // First, get the customers to delete from the source of truth
            guard case .success(let currentCustomers) = viewState else { return }
            let customersToDelete = offsets.map { currentCustomers[$0] }
            
            do {
                for customer in customersToDelete {
                    try await customerService.delete(customer: customer)
                }
                // Refresh data on success by refetching
                await fetchCustomers()
            } catch {
                // Display error
                viewState = .error(error)
            }
        }
    }
}
