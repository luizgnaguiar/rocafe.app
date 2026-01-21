import Foundation

@MainActor
class RecipeListViewModel: ObservableObject, StandardViewModel {
    typealias DataType = [Recipe]
    
    @Published var viewState: ViewState<[Recipe]> = .idle
    @Published var searchText: String = ""
    
    private let recipeService: RecipeService
    private var allRecipes: [Recipe] = []
    
    var filteredRecipes: [Recipe] {
        if searchText.isEmpty {
            return allRecipes
        }
        return allRecipes.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
    }
    
    init(recipeService: RecipeService = RecipeService()) {
        self.recipeService = recipeService
    }
    
    func fetchRecipes() {
        viewState = .loading
        
        let recipes = recipeService.getAll()
        
        if recipes.isEmpty {
            viewState = .empty
        } else {
            allRecipes = recipes
            viewState = .success(recipes)
        }
    }
    
    func deleteRecipe(at offsets: IndexSet) {
        let recipesToDelete = offsets.map { filteredRecipes[$0] }
        
        do {
            for recipe in recipesToDelete {
                try recipeService.delete(recipe: recipe)
            }
            fetchRecipes()
        } catch {
            viewState = .error(error)
        }
    }
}
