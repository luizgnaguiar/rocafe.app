import Foundation

enum ExpenseServiceError: Error, LocalizedError {
    case expenseNotFound(id: Int64)
    case descriptionIsEmpty
    case invalidAmount(amount: Decimal)
    
    var errorDescription: String? {
        switch self {
        case .expenseNotFound(let id):
            return "A despesa com o ID \(id) não foi encontrada."
        case .descriptionIsEmpty:
            return "A descrição da despesa é obrigatória."
        case .invalidAmount(let amount):
            return "O valor da despesa (\(amount)) deve ser maior que zero."
        }
    }
}

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
    
    /// Saves an expense after validating its business rules.
    /// - Parameter expense: The expense to be saved.
    /// - Throws: `ExpenseServiceError` if validation fails.
    func save(expense: inout Expense) throws {
        // Business logic validation lives here, not in the ViewModel.
        if expense.description.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            throw ExpenseServiceError.descriptionIsEmpty
        }
        if expense.amount <= 0 {
            throw ExpenseServiceError.invalidAmount(amount: expense.amount)
        }
        
        try expenseRepo.save(&expense)
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
            throw ExpenseServiceError.expenseNotFound(id: expenseId)
        }
        
        expense.isPaid = true
        expense.paymentDate = paymentDate
        try expenseRepo.save(&expense)
    }
}
