import Foundation

@MainActor
class SupplierListViewModel: ObservableObject, StandardViewModel {
    typealias DataType = [Supplier]
    
    @Published var viewState: ViewState<[Supplier]> = .idle
    @Published var searchText: String = ""
    
    private let supplierService: SupplierService
    private var allSuppliers: [Supplier] = []
    
    var filteredSuppliers: [Supplier] {
        if searchText.isEmpty {
            return allSuppliers
        }
        return allSuppliers.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
    }
    
    init(supplierService: SupplierService = SupplierService()) {
        self.supplierService = supplierService
    }
    
    func fetchSuppliers() {
        viewState = .loading
        
        let suppliers = supplierService.getAll()
        
        if suppliers.isEmpty {
            viewState = .empty
        } else {
            allSuppliers = suppliers
            viewState = .success(suppliers)
        }
    }
    
    func deleteSupplier(at offsets: IndexSet) {
        let suppliersToDelete = offsets.map { filteredSuppliers[$0] }
        
        do {
            for supplier in suppliersToDelete {
                try supplierService.delete(supplier: supplier)
            }
            fetchSuppliers()
        } catch {
            viewState = .error(error)
        }
    }
}
