import Foundation
import Combine

@MainActor
class SupplierDetailViewModel: ObservableObject, StandardViewModel {
    typealias DataType = Supplier
    
    @Published var supplier: Supplier
    @Published var viewState: ViewState<Supplier> = .idle
    
    private let service: SupplierService
    
    init(supplier: Supplier, service: SupplierService? = nil) {
        self.supplier = supplier
        self.service = service ?? SupplierService()  // ← Crie aqui
        self.viewState = .success(supplier)
    }
    
    init(supplierId: Int64, service: SupplierService? = nil) {
        self.supplier = Supplier(id: nil, name: "", isActive: true)
        self.service = service ?? SupplierService()  // ← Crie aqui
        fetchSupplier(withId: supplierId)
    }
    
    private func fetchSupplier(withId id: Int64) {
        viewState = .loading
        Task {
            do {
                let fetchedSupplier = try await service.getById(id)
                self.supplier = fetchedSupplier
                self.viewState = .success(fetchedSupplier)
            } catch {
                self.viewState = .error(error)
            }
        }
    }
    
    func saveSupplier() {
        viewState = .loading
        
        Task {
            do {
                var supplierToSave = self.supplier
                try await service.save(supplier: &supplierToSave)
                self.supplier = supplierToSave
                viewState = .success(supplierToSave)
            } catch {
                viewState = .error(error)
            }
        }
    }
    
    func deleteSupplier() {
        viewState = .loading
        
        Task {
            do {
                try await service.delete(supplier: self.supplier)
                viewState = .success(self.supplier)
            } catch {
                viewState = .error(error)
            }
        }
    }
}
