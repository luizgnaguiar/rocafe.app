import Foundation
import Combine

// A wrapper to hold an ingredient and its quantity for UI purposes
struct RecipeIngredientItem: Identifiable {
    let id = UUID()
    var ingredientId: Int64
    var name: String
    var type: IngredientType
    var quantity: Decimal
}

@MainActor
class RecipeDetailViewModel: ObservableObject {
    
    @Published var recipe: Recipe
    @Published var ingredients: [RecipeIngredientItem] = []
    
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    // Data for pickers
    @Published var allRawMaterials: [Product] = []
    @Published var allSubRecipes: [Recipe] = []
    
    private let recipeRepo: RecipeRepository
    private let productRepo: ProductRepository
    private let recipeService: RecipeService
    
    // Repositories for ingredients would also be needed
    
    init(
        recipe: Recipe,
        recipeRepo: RecipeRepository = RecipeRepositoryImpl(),
        productRepo: ProductRepository = ProductRepositoryImpl(),
        recipeService: RecipeService = RecipeService()
    ) {
        self.recipe = recipe
        self.recipeRepo = recipeRepo
        self.productRepo = productRepo
        self.recipeService = recipeService
    }
    
    func onAppear() {
        fetchInitialData()
    }
    
    func fetchInitialData() {
        isLoading = true
        
        // Fetch ingredients for the recipe
        // TODO: Create a repository method for this
        
        // Fetch products and other recipes for the "Add Ingredient" picker
        self.allRawMaterials = productRepo.getAll().filter { $0.type == .rawMaterial }
        
        // Exclude the current recipe and any that would cause a circular dependency
        self.allSubRecipes = recipeRepo.getAll().filter { $0.id != self.recipe.id }
        
        // TODO: Populate the `ingredients` array from the database
        
        isLoading = false
    }
    
    func addIngredient(id: Int64, type: IngredientType, quantity: Decimal) {
        // --- Placeholder ---
        // 1. Validate: check for circular references if it's a sub-recipe
        // 2. Add the new ingredient to the local `ingredients` array
        // 3. This should eventually save the ingredient to the database
    }
    
    func removeIngredient(at offsets: IndexSet) {
        ingredients.remove(atOffsets: offsets)
        // This should also remove the ingredient from the database
    }
    
    func saveRecipe() {
        // This is a complex operation that should use the RecipeService
        // to handle versioning and cost recalculation.
        
        isLoading = true
        errorMessage = nil
        
        // Use a background task for this, as it could be slow
        Task {
            // --- Placeholder for service call ---
            // recipeService.updateRecipe(recipeId: recipe.id, ...)
            
            // After saving, recalculate the cost
            await recipeService.recalculateCost(for: recipe.id!)
            
            // Fetch the updated recipe to get the new version and cost
            if let updatedRecipe = recipeRepo.get(id: recipe.id!) {
                self.recipe = updatedRecipe
            }
            
            isLoading = false
        }
    }
}
