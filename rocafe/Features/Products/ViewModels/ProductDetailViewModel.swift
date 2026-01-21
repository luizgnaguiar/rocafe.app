import Foundation

@MainActor
class ProductDetailViewModel: ObservableObject, StandardViewModel {
    typealias DataType = Product
    
    @Published var viewState: ViewState<Product> = .idle
    @Published var product: Product
    
    @Published var allSuppliers: [Supplier] = []
    @Published var allRecipes: [Recipe] = []
    
    private let productService: ProductService
    private let supplierService: SupplierService
    private let recipeService: RecipeService
    
    init(
        product: Product?,
        productService: ProductService = ProductService(),
        supplierService: SupplierService = SupplierService(),
        recipeService: RecipeService = RecipeService()
    ) {
        self.product = product ?? Product(id: nil, name: "", type: .finished, category: .ready, isActive: true)
        self.productService = productService
        self.supplierService = supplierService
        self.recipeService = recipeService
        
        if product != nil {
            self.viewState = .success(self.product)
        }
    }
    
    func fetchRequiredData() {
        if case .success = viewState {
             // Data is already loaded
        } else {
            viewState = .loading
        }
        
        // Fetch auxiliary data
        self.allSuppliers = supplierService.getAll()
        self.allRecipes = recipeService.getAll()
        
        if self.product.id == nil {
            // This is a new product, no need to fetch it.
            viewState = .success(self.product)
        }
        // If it's an existing product, it's already loaded from the initializer.
        // If we needed to fetch it by ID, we would do it here and update the state.
    }
    
    func saveProduct() {
        viewState = .loading
        Task {
            do {
                var productToSave = self.product
                try productService.save(product: &productToSave)
                self.product = productToSave
                viewState = .success(productToSave)
            } catch {
                viewState = .error(error)
            }
        }
    }
    
    func deleteProduct() {
        viewState = .loading
        Task {
            do {
                try productService.delete(product: self.product)
                viewState = .success(self.product) // To signal dismissal
            } catch {
                viewState = .error(error)
            }
        }
    }
}
