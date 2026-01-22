import Foundation

@MainActor
class ProductListViewModel: ObservableObject, StandardViewModel {
    typealias DataType = [Product]
    
    @Published var viewState: ViewState<[Product]> = .idle
    @Published var searchText: String = ""
    @Published var productTypeFilter: ProductType? = nil
    
    private let productService: ProductService
    
    var filteredProducts: [Product] {
        guard case .success(let products) = viewState else { return [] }

        var filtered = products
        
        if let type = productTypeFilter {
            filtered = filtered.filter { $0.type == type }
        }
        
        if !searchText.isEmpty {
            let lowercasedText = searchText.lowercased()
            filtered = filtered.filter { $0.name.lowercased().contains(lowercasedText) }
        }
        
        return filtered
    }
    
    init(productService: ProductService = ProductService()) {
        self.productService = productService
    }
    
    func fetchProducts() async {
        viewState = .loading
        do {
            let products = try await productService.getAll()
            if products.isEmpty {
                viewState = .empty
            } else {
                viewState = .success(products)
            }
        } catch {
            viewState = .error(error)
        }
    }
    
    func deleteProduct(at offsets: IndexSet) async {
        guard case .success(let products) = viewState else { return }
        
        let productsToDelete = offsets.map { products[$0] }
        
        do {
            for product in productsToDelete {
                try await productService.delete(product: product)
            }
            await fetchProducts() // Refetch to update the UI
        } catch {
            viewState = .error(error)
        }
    }
}
