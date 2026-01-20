import Foundation
import Combine

@MainActor
class ProductListViewModel: ObservableObject {
    
    @Published var allProducts: [Product] = []
    @Published var filteredProducts: [Product] = []
    
    @Published var searchText: String = ""
    @Published var productTypeFilter: ProductType? = nil
    
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let repository: ProductRepository
    private var cancellables = Set<AnyCancellable>()
    
    init(repository: ProductRepository = ProductRepositoryImpl()) {
        self.repository = repository
        
        // Combine pipeline to filter products based on search text and type
        $searchText
            .combineLatest($productTypeFilter, $allProducts)
            .debounce(for: .milliseconds(300), scheduler: RunLoop.main)
            .map { (text, type, products) -> [Product] in
                var filtered = products
                
                // Filter by product type
                if let type = type {
                    filtered = filtered.filter { $0.type == type }
                }
                
                // Filter by search text
                if !text.isEmpty {
                    let lowercasedText = text.lowercased()
                    filtered = filtered.filter { $0.name.lowercased().contains(lowercasedText) }
                }
                
                return filtered
            }
            .assign(to: \.filteredProducts, on: self)
            .store(in: &cancellables)
    }
    
    func fetchProducts() {
        isLoading = true
        errorMessage = nil
        
        // In a real app, repository calls should be asynchronous
        // and this would be handled with `async/await`.
        let products = repository.getAll()
        self.allProducts = products
        
        isLoading = false
    }
    
    func deleteProduct(at offsets: IndexSet) {
        let productsToDelete = offsets.map { filteredProducts[$0] }
        
        productsToDelete.forEach { product in
            guard let productId = product.id else { return }
            if repository.delete(id: productId) {
                // If deletion is successful, remove from the main list
                allProducts.removeAll { $0.id == productId }
            }
        }
    }
}
