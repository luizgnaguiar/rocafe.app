import Foundation

@MainActor
class ProductDetailViewModel: ObservableObject, StandardViewModel {
    typealias DataType = Product
    
    @Published var viewState: ViewState<Product> = .idle
    @Published var product: Product
    
    // Data for pickers
    @Published var allSuppliers: [Supplier] = []
    @Published var allRecipes: [Recipe] = []
    
    private let productService: ProductService
    private let supplierService: SupplierService
    private let recipeService: RecipeService
    
    init(
        product: Product?,
        productService: ProductService? = nil,
        supplierService: SupplierService? = nil,
        recipeService: RecipeService? = nil
    ) {
        self.product = product ?? Product(id: nil, name: "", type: .rawMaterial, isActive: true)
        self.productService = productService ?? ProductService()
        self.supplierService = supplierService ?? SupplierService()
        self.recipeService = recipeService ?? RecipeService()
        
        if let existingProduct = product {
            self.viewState = .success(existingProduct)
        }
    }
    
    func fetchRequiredData() async {
        // Only fetch if we haven't loaded or failed before
        if case .success = viewState { return }
        
        viewState = .loading
        do {
            // Fetch auxiliary data in parallel
            async let suppliers = try supplierService.getAll()
            async let recipes = try recipeService.getAll()
            
            self.allSuppliers = try await suppliers
            self.allRecipes = try await recipes
            
            // If we're creating a new product, we're ready.
            // If editing, the product is already loaded.
            viewState = .success(self.product)
        } catch {
            viewState = .error(error)
        }
    }
    
    func saveProduct() async {
        viewState = .loading
        do {
            var productToSave = self.product
            try await productService.save(product: &productToSave)
            self.product = productToSave
            viewState = .success(productToSave)
        } catch {
            viewState = .error(error)
        }
    }
    
    func deleteProduct() async {
        viewState = .loading
        do {
            try await productService.delete(product: self.product)
            viewState = .success(self.product) // To signal dismissal
        } catch {
            viewState = .error(error)
        }
    }
}