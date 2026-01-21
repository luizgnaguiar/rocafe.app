import XCTest
import GRDB
@testable import rocafe

@MainActor
final class FinancialCalculationsTests: XCTestCase {
    
    private var dbPool: DatabasePool!
    private var recipeService: RecipeService!
    private var productRepo: ProductRepository!
    private var recipeRepo: RecipeRepository!
    private var ingredientRepo: RecipeIngredientRepository!

    override func setUpWithError() throws {
        try super.setUpWithError()
        dbPool = try TestDatabase.newPool()
        
        // Initialize repositories with the test pool
        productRepo = ProductRepositoryImpl(dbPool: dbPool)
        recipeRepo = RecipeRepositoryImpl(dbPool: dbPool)
        ingredientRepo = RecipeIngredientRepositoryImpl(dbPool: dbPool)
        
        // Initialize the service with the test repositories
        recipeService = RecipeService(
            recipeRepo: recipeRepo,
            ingredientRepo: ingredientRepo,
            productRepo: productRepo,
            dbPool: dbPool
        )
    }

    override func tearDownWithError() throws {
        dbPool = nil
        recipeService = nil
        productRepo = nil
        recipeRepo = nil
        ingredientRepo = nil
        try super.tearDownWithError()
    }
    
    // MARK: - Block 2.1: Financial Tests
    
    func test_RecipeCost_Simple() async throws {
        // MARK: Arrange
        // 1. Create raw material products (ingredients) with a purchase price
        var coffee = Product(name: "Coffee Beans", type: .rawMaterial, purchasePrice: 10.50, isActive: true)
        var milk = Product(name: "Milk", type: .rawMaterial, purchasePrice: 2.00, isActive: true)
        try await productRepo.save(&coffee)
        try await productRepo.save(&milk)
        
        // 2. Create the manufactured product that will have a recipe
        var cappuccinoProduct = Product(name: "Cappuccino", type: .manufactured, salePrice: 15.00, isActive: true)
        try await productRepo.save(&cappuccinoProduct)
        
        // 3. Create the recipe associated with the manufactured product
        var recipe = Recipe(productId: cappuccinoProduct.id!, name: "Cappuccino Recipe", version: 1, totalCost: 0, isActive: true)
        try await recipeRepo.save(&recipe)
        
        // Link recipe back to product (important for recursive lookups)
        cappuccinoProduct.recipeId = recipe.id
        try await productRepo.save(&cappuccinoProduct)
        
        // 4. Create ingredients for the recipe
        var coffeeIngredient = RecipeIngredient(recipeId: recipe.id!, productId: coffee.id!, quantity: 0.1) // 100g
        var milkIngredient = RecipeIngredient(recipeId: recipe.id!, productId: milk.id!, quantity: 0.2) // 200ml
        try await ingredientRepo.save(&coffeeIngredient)
        try await ingredientRepo.save(&milkIngredient)
        
        // MARK: Act
        // Recalculate the cost for our main recipe
        let calculatedCost = try await recipeService.recalculateCost(for: recipe.id!)
        
        // MARK: Assert
        // Fetch the recipe again to see the updated cost from the DB
        let updatedRecipe = try await recipeRepo.get(id: recipe.id!)
        
        let expectedCost = (10.50 * 0.1) + (2.00 * 0.2) // 1.05 + 0.40 = 1.45
        
        XCTAssertEqual(calculatedCost, expectedCost, "The calculated cost returned by the service should be correct.")
        XCTAssertEqual(updatedRecipe?.totalCost, expectedCost, "The totalCost field in the database should be updated correctly.")
    }
    
    func test_RecipeCost_Nested() async throws {
        // MARK: Arrange (Level 1: Dough)
        // 1. Base raw materials
        var flour = Product(name: "Flour", type: .rawMaterial, purchasePrice: 1.50, isActive: true)
        var sugar = Product(name: "Sugar", type: .rawMaterial, purchasePrice: 2.50, isActive: true)
        try await productRepo.save(&flour)
        try await productRepo.save(&sugar)
        
        // 2. Sub-recipe product ("Dough")
        var doughProduct = Product(name: "Dough", type: .manufactured, isActive: true)
        try await productRepo.save(&doughProduct)
        
        // 3. Recipe for "Dough"
        var doughRecipe = Recipe(productId: doughProduct.id!, name: "Dough Recipe", version: 1, totalCost: 0, isActive: true)
        try await recipeRepo.save(&doughRecipe)
        doughProduct.recipeId = doughRecipe.id
        try await productRepo.save(&doughProduct)
        
        // 4. Ingredients for "Dough"
        var flourIngredient = RecipeIngredient(recipeId: doughRecipe.id!, productId: flour.id!, quantity: 0.5) // 500g
        var sugarIngredient = RecipeIngredient(recipeId: doughRecipe.id!, productId: sugar.id!, quantity: 0.2) // 200g
        try await ingredientRepo.save(&flourIngredient)
        try await ingredientRepo.save(&sugarIngredient)
        
        // MARK: Act (Level 1)
        let doughCost = try await recipeService.recalculateCost(for: doughRecipe.id!)
        
        // MARK: Assert (Level 1)
        let expectedDoughCost = (1.50 * 0.5) + (2.50 * 0.2) // 0.75 + 0.50 = 1.25
        XCTAssertEqual(doughCost, expectedDoughCost)
        
        // MARK: Arrange (Level 2: Cake)
        // 5. Additional raw material for the final product
        var icing = Product(name: "Icing", type: .rawMaterial, purchasePrice: 5.00, isActive: true)
        try await productRepo.save(&icing)
        
        // 6. Final manufactured product ("Cake")
        var cakeProduct = Product(name: "Cake", type: .manufactured, isActive: true)
        try await productRepo.save(&cakeProduct)
        
        // 7. Recipe for "Cake"
        var cakeRecipe = Recipe(productId: cakeProduct.id!, name: "Cake Recipe", version: 1, totalCost: 0, isActive: true)
        try await recipeRepo.save(&cakeRecipe)
        cakeProduct.recipeId = cakeRecipe.id
        try await productRepo.save(&cakeProduct)

        // 8. Ingredients for "Cake" (using the Dough product and Icing)
        var doughAsIngredient = RecipeIngredient(recipeId: cakeRecipe.id!, productId: doughProduct.id!, quantity: 1.0) // 1 unit of dough
        var icingIngredient = RecipeIngredient(recipeId: cakeRecipe.id!, productId: icing.id!, quantity: 0.5) // 500g of icing
        try await ingredientRepo.save(&doughAsIngredient)
        try await ingredientRepo.save(&icingIngredient)
        
        // MARK: Act (Level 2)
        let cakeCost = try await recipeService.recalculateCost(for: cakeRecipe.id!)
        
        // MARK: Assert (Level 2)
        let updatedCakeRecipe = try await recipeRepo.get(id: cakeRecipe.id!)
        let expectedCakeCost = (doughCost * 1.0) + (5.00 * 0.5) // 1.25 + 2.50 = 3.75
        
        XCTAssertEqual(cakeCost, expectedCakeCost, "The final cake cost should include the calculated cost of the sub-recipe.")
        XCTAssertEqual(updatedCakeRecipe?.totalCost, expectedCakeCost, "The cake recipe's cost in DB should be updated correctly.")
    }
}
