import Foundation
import Combine

@MainActor
class CustomerListViewModel: ObservableObject {
    
    @Published var allCustomers: [Customer] = []
    @Published var filteredCustomers: [Customer] = []
    
    @Published var searchText: String = ""
    
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let repository: CustomerRepository
    private var cancellables = Set<AnyCancellable>()
    
    init(repository: CustomerRepository = CustomerRepositoryImpl()) {
        self.repository = repository
        
        $searchText
            .combineLatest($allCustomers)
            .debounce(for: .milliseconds(300), scheduler: RunLoop.main)
            .map { (text, customers) -> [Customer] in
                if text.isEmpty {
                    return customers
                }
                let lowercasedText = text.lowercased()
                return customers.filter { $0.name.lowercased().contains(lowercasedText) }
            }
            .assign(to: \.filteredCustomers, on: self)
            .store(in: &cancellables)
    }
    
    func fetchCustomers() {
        isLoading = true
        errorMessage = nil
        
        self.allCustomers = repository.getAll()
        
        isLoading = false
    }
    
    func deleteCustomer(at offsets: IndexSet) {
        let customersToDelete = offsets.map { filteredCustomers[$0] }
        
        customersToDelete.forEach { customer in
            guard let customerId = customer.id else { return }
            if repository.delete(id: customerId) {
                allCustomers.removeAll { $0.id == customerId }
            }
        }
    }
}
