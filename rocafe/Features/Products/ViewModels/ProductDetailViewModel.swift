import Foundation
import Combine

@MainActor
class ProductDetailViewModel: ObservableObject {
    
    @Published var product: Product
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    // Properties for picking related items
    @Published var allSuppliers: [Supplier] = []
    @Published var allRecipes: [Recipe] = []
    
    private let productRepo: ProductRepository
    private let supplierRepo: SupplierRepository
    private let recipeRepo: RecipeRepository
    
    init(
        product: Product?,
        productRepo: ProductRepository = ProductRepositoryImpl(),
        supplierRepo: SupplierRepository = SupplierRepositoryImpl(),
        recipeRepo: RecipeRepository = RecipeRepositoryImpl()
    ) {
        self.product = product ?? Product(id: nil, name: "", type: .finished, category: .ready, isActive: true)
        self.productRepo = productRepo
        self.supplierRepo = supplierRepo
        self.recipeRepo = recipeRepo
    }
    
    func onAppear() {
        // Fetch related data needed for pickers, etc.
        self.allSuppliers = supplierRepo.getAll()
        // Only fetch recipes if this is a manufactured product
        if product.category == .manufactured {
            self.allRecipes = recipeRepo.getAll()
        }
    }
    
    func saveProduct() {
        guard validate() else { return }
        
        isLoading = true
        errorMessage = nil
        
        do {
            var productToSave = self.product
            
            // Adjust data based on type
            if productToSave.type == .rawMaterial {
                productToSave.category = nil
                productToSave.salePrice = nil
                productToSave.recipeId = nil
            } else if productToSave.category == .ready {
                productToSave.recipeId = nil
            }
            
            try productRepo.save(&productToSave)
            self.product = productToSave
            
        } catch {
            errorMessage = "Falha ao salvar o produto: \(error.localizedDescription)"
        }
        
        isLoading = false
    }
    
    private func validate() -> Bool {
        // Name is required
        if product.name.trimmingCharacters(in: .whitespaces).isEmpty {
            errorMessage = "O nome do produto é obrigatório."
            return false
        }
        
        // Sale price must be >= cost
        if let salePrice = product.salePrice {
            let cost = product.purchasePrice ?? product.manufacturingCost ?? 0
            if salePrice < cost {
                errorMessage = "O preço de venda não pode ser menor que o custo."
                return false
            }
        }
        
        // Manufactured product must have a recipe
        if product.category == .manufactured && product.recipeId == nil {
            errorMessage = "Um produto de fabricação própria deve ter uma receita associada."
            return false
        }
        
        errorMessage = nil
        return true
    }
}
