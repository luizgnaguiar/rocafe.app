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
    
    func fetchSuppliers() async {
        viewState = .loading
        
        do {
            let suppliers = try await supplierService.getAll()
            
            if suppliers.isEmpty {
                viewState = .empty
            } else {
                allSuppliers = suppliers
                viewState = .success(suppliers)
            }
        } catch {
            viewState = .error(error)
        }
    }
    
    func deleteSupplier(at offsets: IndexSet) async {
        let suppliersToDelete = offsets.map { filteredSuppliers[$0] }
        
        do {
            for supplier in suppliersToDelete {
                try await supplierService.delete(supplier: supplier)
            }
            await fetchSuppliers()
        } catch {
            viewState = .error(error)
        }
    }
}
