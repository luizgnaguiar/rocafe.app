import Foundation
import Combine

@MainActor
class SupplierListViewModel: ObservableObject {
    
    @Published var allSuppliers: [Supplier] = []
    @Published var filteredSuppliers: [Supplier] = []
    
    @Published var searchText: String = ""
    
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let repository: SupplierRepository
    private var cancellables = Set<AnyCancellable>()
    
    init(repository: SupplierRepository = SupplierRepositoryImpl()) {
        self.repository = repository
        
        $searchText
            .combineLatest($allSuppliers)
            .debounce(for: .milliseconds(300), scheduler: RunLoop.main)
            .map { (text, suppliers) -> [Supplier] in
                if text.isEmpty {
                    return suppliers
                }
                let lowercasedText = text.lowercased()
                return suppliers.filter { $0.name.lowercased().contains(lowercasedText) }
            }
            .assign(to: \.filteredSuppliers, on: self)
            .store(in: &cancellables)
    }
    
    func fetchSuppliers() {
        isLoading = true
        errorMessage = nil
        
        self.allSuppliers = repository.getAll()
        
        isLoading = false
    }
    
    func deleteSupplier(at offsets: IndexSet) {
        let suppliersToDelete = offsets.map { filteredSuppliers[$0] }
        
        suppliersToDelete.forEach { supplier in
            guard let supplierId = supplier.id else { return }
            if repository.delete(id: supplierId) {
                allSuppliers.removeAll { $0.id == supplierId }
            }
        }
    }
}
