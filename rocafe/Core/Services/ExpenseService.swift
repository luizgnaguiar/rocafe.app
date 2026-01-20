import Foundation

class ExpenseService {
    
    private let recurringExpenseRepo: RecurringExpenseRepository
    private let expenseRepo: ExpenseRepository
    
    init(
        recurringExpenseRepo: RecurringExpenseRepository = RecurringExpenseRepositoryImpl(),
        expenseRepo: ExpenseRepository = ExpenseRepositoryImpl()
    ) {
        self.recurringExpenseRepo = recurringExpenseRepo
        self.expenseRepo = expenseRepo
    }
    
    /// Checks for and generates any recurring expenses that are due for the current month.
    /// This should be called on app launch or on a regular basis.
    func generateMonthlyExpenses() {
        // --- Placeholder Logic ---
        // 1. Get all active recurring expenses from the repository.
        // 2. For each recurring expense, check if an expense has already been
        //    generated for the current month and year.
        // 3. If not, create a new Expense object based on the RecurringExpense template.
        //    - Set the due date based on the 'dayOfMonth'.
        //    - Set the description, category, amount, etc.
        // 4. Save the new Expense to the database using the expense repository.
        //
        // This process requires careful handling of dates and timezones to be robust.
        print("Checking for and generating recurring expenses...")
    }
    
    /// Marks a specific expense as paid.
    /// - Parameters:
    ///   - expenseId: The ID of the expense to mark as paid.
    ///   - paymentDate: The date the expense was paid.
    func payExpense(expenseId: Int64, paymentDate: Date) throws {
        guard var expense = expenseRepo.get(id: expenseId) else {
            // In a real app, throw a custom error
            throw NSError(domain: "ExpenseService", code: 404, userInfo: [NSLocalizedDescriptionKey: "Expense not found"])
        }
        
        expense.isPaid = true
        expense.paymentDate = paymentDate
        try expenseRepo.save(&expense)
    }
}
