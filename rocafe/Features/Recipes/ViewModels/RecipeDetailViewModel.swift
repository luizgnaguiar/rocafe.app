import Foundation
import Combine

struct RecipeIngredientItem: Identifiable, Equatable {
    let id = UUID()
    var productId: Int64 // This now consistently refers to the Product ID of the ingredient
    var name: String
    var quantity: Decimal
    
    static func == (lhs: RecipeIngredientItem, rhs: RecipeIngredientItem) -> Bool {
        return lhs.id == rhs.id
    }
}

@MainActor
class RecipeDetailViewModel: ObservableObject, StandardViewModel {
    typealias DataType = (recipe: Recipe, ingredients: [RecipeIngredientItem])
    
    @Published var viewState: ViewState<DataType> = .idle
    @Published var recipe: Recipe
    @Published var ingredients: [RecipeIngredientItem] = []
    
    // Data for pickers
    @Published var allRawMaterials: [Product] = []
    @Published var allManufacturedProducts: [Product] = []
    
    private let recipeService: RecipeService
    private let productService: ProductService
    
    init(
        recipe: Recipe,
        recipeService: RecipeService? = nil,
        productService: ProductService? = nil
    ) {
        self.recipe = recipe
        self.recipeService = recipeService ?? RecipeService()
        self.productService = productService ?? ProductService()
    }
    
    func fetchData() async {
        viewState = .loading
        do {
            // Fetch all data in parallel
            async let fetchedData = try recipeService.getRecipeWithIngredients(id: recipe.id!)
            async let rawMaterials = try productService.getRawMaterials()
            async let allProducts = try productService.getAll() // Needed to get names

            let (fetchedRecipe, fetchedIngredients) = try await fetchedData
            self.allRawMaterials = try await rawMaterials
            let products = try await allProducts
            
            // Exclude the current recipe's product from being an ingredient in itself
            self.allManufacturedProducts = products.filter { $0.type == .manufactured && $0.id != self.recipe.productId }

            self.recipe = fetchedRecipe
            
            // Map ingredients to UI items
            self.ingredients = try fetchedIngredients.map { ingredient in
                guard let product = products.first(where: { $0.id == ingredient.productId }) else {
                    throw RecipeServiceError.notFound // Or a more specific error
                }
                return RecipeIngredientItem(productId: product.id!, name: product.name, quantity: ingredient.quantity)
            }
            
            viewState = .success((self.recipe, self.ingredients))
        } catch {
            viewState = .error(error)
        }
    }
    
    func addIngredient(product: Product, quantity: Decimal) {
        let newItem = RecipeIngredientItem(productId: product.id!, name: product.name, quantity: quantity)
        ingredients.append(newItem)
    }
    
    func removeIngredient(at offsets: IndexSet) {
        ingredients.remove(atOffsets: offsets)
    }
    
    func saveRecipe() async {
        viewState = .loading
        do {
            var recipeToSave = self.recipe
            
            // Map UI items back to model objects
            let ingredientsToSave = ingredients.map {
                RecipeIngredient(recipeId: recipeToSave.id!, productId: $0.productId, quantity: $0.quantity)
            }
            
            // The save method in the service now handles recalculation
            try await recipeService.save(recipe: &recipeToSave, ingredients: ingredientsToSave)
            
            let updatedRecipe = try await recipeService.getById(recipeToSave.id!)
            self.recipe = updatedRecipe
            
            viewState = .success((updatedRecipe, self.ingredients))
            
        } catch {
            viewState = .error(error)
        }
    }
}