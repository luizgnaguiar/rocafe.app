import Foundation
import GRDB

@MainActor
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
    
    func save(expense: inout Expense) async throws {
        if expense.description.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            throw ExpenseServiceError.descriptionIsEmpty
        }
        if expense.amount <= 0 {
            throw ExpenseServiceError.invalidAmount
        }
        
        var expenseToSave = expense
        try await Task {
            try expenseRepo.save(&expenseToSave)
        }.value
        expense = expenseToSave
    }
    
    func payExpense(expenseId: Int64, paymentDate: Date) async throws {
        guard var expense = try await Task({ try expenseRepo.get(id: expenseId) }).value else {
            throw ExpenseServiceError.notFound
        }
        
        expense.isPaid = true
        expense.paymentDate = paymentDate
        
        try await save(expense: &expense)
    }

    func delete(expense: Expense) async throws {
        guard let expenseId = expense.id else { return }
        let success = try await Task {
            try expenseRepo.delete(id: expenseId)
        }.value
        if !success {
            throw ExpenseServiceError.deleteFailed
        }
    }
    
    func generateMonthlyExpenses() async throws {
        // --- Placeholder Logic ---
        // This should be implemented using the async repositories.
        print("Checking for and generating recurring expenses...")
    }
}

enum ExpenseServiceError: LocalizedError {
    case notFound
    case descriptionIsEmpty
    case invalidAmount
    case deleteFailed
    
    var errorDescription: String? {
        switch self {
        case .notFound:
            return "A despesa não foi encontrada."
        case .descriptionIsEmpty:
            return "A descrição da despesa é obrigatória."
        case .invalidAmount:
            return "O valor da despesa deve ser maior que zero."
        case .deleteFailed:
            return "Falha ao deletar a despesa."
        }
    }
}