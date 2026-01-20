import Foundation

class CalculationService {
    
    /// Calculates the profit margin for a given product.
    /// - Parameters:
    ///   - salePrice: The price the product is sold for.
    ///   - cost: The cost of the product (either purchase price or manufacturing cost).
    /// - Returns: The profit margin as a decimal (e.g., 0.25 for 25%), or nil if inputs are invalid.
    static func calculateProfitMargin(salePrice: Decimal, cost: Decimal) -> Decimal? {
        guard salePrice > 0, cost > 0, salePrice > cost else {
            return nil
        }
        return (salePrice - cost) / salePrice
    }
    
    /// Recursively calculates the total cost of a recipe.
    /// This is a placeholder and the actual implementation will be more complex,
    /// involving database fetches for ingredient costs.
    /// - Parameter recipe: The recipe to calculate the cost for.
    /// - Returns: The total calculated cost.
    static func calculateRecipeCost(recipe: Recipe) -> Decimal {
        // NOTE: This is a simplified placeholder.
        // The actual implementation in RecipeService will be asynchronous and
        // will fetch ingredients and their costs from the database.
        return recipe.totalCost // Returning the cached cost for now.
    }
    
    /// Calculates the simplified DRE (Statement of Income).
    /// - Parameters:
    ///   - totalRevenue: Total revenue (sales + received payments).
    ///   - totalExpenses: Total expenses.
    /// - Returns: The net result for the period.
    static func calculateSimplifiedDRE(totalRevenue: Decimal, totalExpenses: Decimal) -> Decimal {
        return totalRevenue - totalExpenses
    }
}
