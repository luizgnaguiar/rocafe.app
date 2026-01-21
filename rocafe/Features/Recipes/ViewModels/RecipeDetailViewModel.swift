import Foundation
import Combine

struct RecipeIngredientItem: Identifiable, Equatable {
    let id = UUID()
    var ingredientId: Int64
    var name: String
    var type: IngredientType
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
    
    @Published var allRawMaterials: [Product] = []
    @Published var allSubRecipes: [Recipe] = []
    
    private let recipeService: RecipeService
    private let productService: ProductService
    
    init(
        recipe: Recipe,
        recipeService: RecipeService = RecipeService(),
        productService: ProductService = ProductService()
    ) {
        self.recipe = recipe
        self.recipeService = recipeService
        self.productService = productService
    }
    
    func fetchData() {
        viewState = .loading
        Task {
            do {
                let (fetchedRecipe, fetchedIngredients) = try recipeService.getRecipeWithIngredients(id: recipe.id!)
                self.recipe = fetchedRecipe
                
                // Fetch data for pickers
                self.allRawMaterials = productService.getRawMaterials()
                self.allSubRecipes = recipeService.getAll().filter { $0.id != self.recipe.id }
                
                // Map ingredients to UI items
                var ingredientItems: [RecipeIngredientItem] = []
                for ingredient in fetchedIngredients {
                    let name: String
                    if ingredient.ingredientType == .rawMaterial, let productId = ingredient.ingredientProductId {
                        name = allRawMaterials.first { $0.id == productId }?.name ?? "Ingrediente Desconhecido"
                    } else if ingredient.ingredientType == .subRecipe, let subRecipeId = ingredient.ingredientRecipeId {
                        name = allSubRecipes.first { $0.id == subRecipeId }?.name ?? "Sub-receita Desconhecida"
                    } else {
                        name = "Ingrediente Inválido"
                    }
                    
                    ingredientItems.append(.init(
                        ingredientId: ingredient.id!,
                        name: name,
                        type: ingredient.ingredientType,
                        quantity: ingredient.quantity
                    ))
                }
                self.ingredients = ingredientItems
                
                viewState = .success((recipe, ingredientItems))
            } catch {
                viewState = .error(error)
            }
        }
    }
    
    func addIngredient(id: Int64, type: IngredientType, name: String, quantity: Decimal) {
        let newItem = RecipeIngredientItem(ingredientId: id, name: name, type: type, quantity: quantity)
        ingredients.append(newItem)
    }
    
    func removeIngredient(at offsets: IndexSet) {
        ingredients.remove(atOffsets: offsets)
    }
    
    func saveRecipe() {
        viewState = .loading
        Task {
            do {
                var recipeToSave = self.recipe
                
                let ingredientsToSave = ingredients.map { item -> RecipeIngredient in
                    if item.type == .rawMaterial {
                        return RecipeIngredient(recipeId: recipeToSave.id!, ingredientType: .rawMaterial, ingredientProductId: item.ingredientId, quantity: item.quantity)
                    } else {
                        return RecipeIngredient(recipeId: recipeToSave.id!, ingredientType: .subRecipe, ingredientRecipeId: item.ingredientId, quantity: item.quantity)
                    }
                }
                
                try recipeService.save(recipe: &recipeToSave, ingredients: ingredientsToSave)
                
                await recipeService.recalculateCost(for: recipeToSave.id!)
                
                let updatedRecipe = try recipeService.getById(recipeToSave.id!)
                self.recipe = updatedRecipe
                
                viewState = .success((updatedRecipe, ingredients))
                
            } catch {
                viewState = .error(error)
            }
        }
    }
}
