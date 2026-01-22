import Foundation

@MainActor
class RecipeListViewModel: ObservableObject, StandardViewModel {
    typealias DataType = [Recipe]
    
    @Published var viewState: ViewState<[Recipe]> = .idle
    @Published var searchText: String = ""
    
    private let recipeService: RecipeService
    
    var filteredRecipes: [Recipe] {
        guard case .success(let recipes) = viewState else { return [] }
        if searchText.isEmpty {
            return recipes
        }
        return recipes.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
    }
    
    init(recipeService: RecipeService? = nil) {
        self.recipeService = recipeService ?? RecipeService()
    }
    
    func fetchRecipes() async {
        viewState = .loading
        do {
            let recipes = try await recipeService.getAll()
            if recipes.isEmpty {
                viewState = .empty
            } else {
                viewState = .success(recipes)
            }
        } catch {
            viewState = .error(error)
        }
    }
    
    func deleteRecipe(at offsets: IndexSet) async {
        guard case .success(let recipes) = viewState else { return }
        
        let recipesToDelete = offsets.map { recipes[$0] }
        
        do {
            for recipe in recipesToDelete {
                try await recipeService.delete(recipe: recipe)
            }
            await fetchRecipes()
        } catch {
            viewState = .error(error)
        }
    }
}