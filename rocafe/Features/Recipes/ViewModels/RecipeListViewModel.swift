import Foundation
import Combine

@MainActor
class RecipeListViewModel: ObservableObject {
    
    @Published var allRecipes: [Recipe] = []
    @Published var filteredRecipes: [Recipe] = []
    
    @Published var searchText: String = ""
    
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let repository: RecipeRepository
    private var cancellables = Set<AnyCancellable>()
    
    init(repository: RecipeRepository = RecipeRepositoryImpl()) {
        self.repository = repository
        
        $searchText
            .combineLatest($allRecipes)
            .debounce(for: .milliseconds(300), scheduler: RunLoop.main)
            .map { (text, recipes) -> [Recipe] in
                if text.isEmpty {
                    return recipes
                }
                let lowercasedText = text.lowercased()
                return recipes.filter { $0.name.lowercased().contains(lowercasedText) }
            }
            .assign(to: \.filteredRecipes, on: self)
            .store(in: &cancellables)
    }
    
    func fetchRecipes() {
        isLoading = true
        errorMessage = nil
        
        self.allRecipes = repository.getAll()
        
        isLoading = false
    }
    
    func deleteRecipe(at offsets: IndexSet) {
        let recipesToDelete = offsets.map { filteredRecipes[$0] }
        
        recipesToDelete.forEach { recipe in
            guard let recipeId = recipe.id else { return }
            // Note: Deleting a recipe might have cascading effects that need to be handled.
            // For example, what happens to products that use this recipe?
            // The database schema uses onDelete: .setNull for the product's recipeId.
            if repository.delete(id: recipeId) {
                allRecipes.removeAll { $0.id == recipeId }
            }
        }
    }
}
