import Foundation
import Combine

@MainActor
class SupplierDetailViewModel: ObservableObject {
    
    @Published var supplier: Supplier
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let repository: SupplierRepository
    
    init(supplier: Supplier?, repository: SupplierRepository = SupplierRepositoryImpl()) {
        self.supplier = supplier ?? Supplier(id: nil, name: "", isActive: true)
        self.repository = repository
    }
    
    func saveSupplier() {
        guard validate() else { return }
        
        isLoading = true
        errorMessage = nil
        
        do {
            var supplierToSave = self.supplier
            try repository.save(&supplierToSave)
            self.supplier = supplierToSave
        } catch {
            errorMessage = "Falha ao salvar o fornecedor: \(error.localizedDescription)"
        }
        
        isLoading = false
    }
    
    private func validate() -> Bool {
        if supplier.name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            errorMessage = "O nome do fornecedor é obrigatório."
            return false
        }
        
        // TODO: Add CNPJ validation if needed
        
        errorMessage = nil
        return true
    }
}
