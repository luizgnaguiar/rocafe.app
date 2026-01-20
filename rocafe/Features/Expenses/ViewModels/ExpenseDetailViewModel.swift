import Foundation
import Combine

@MainActor
class ExpenseDetailViewModel: ObservableObject {
    
    @Published var expense: Expense
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    // For pickers
    @Published var allSuppliers: [Supplier] = []
    
    private let expenseRepo: ExpenseRepository
    private let supplierRepo: SupplierRepository
    
    init(
        expense: Expense?,
        expenseRepo: ExpenseRepository = ExpenseRepositoryImpl(),
        supplierRepo: SupplierRepository = SupplierRepositoryImpl()
    ) {
        self.expense = expense ?? Expense(id: nil, description: "", category: .contas, amount: 0, dueDate: Date(), isPaid: false, wasAdjusted: false)
        self.expenseRepo = expenseRepo
        self.supplierRepo = supplierRepo
    }
    
    func onAppear() {
        self.allSuppliers = supplierRepo.getAll()
    }
    
    func saveExpense() {
        guard validate() else { return }
        
        isLoading = true
        errorMessage = nil
        
        do {
            var expenseToSave = self.expense
            try expenseRepo.save(&expenseToSave)
            self.expense = expenseToSave
        } catch {
            errorMessage = "Falha ao salvar a despesa: \(error.localizedDescription)"
        }
        
        isLoading = false
    }
    
    private func validate() -> Bool {
        if expense.description.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            errorMessage = "A descrição da despesa é obrigatória."
            return false
        }
        if expense.amount <= 0 {
            errorMessage = "O valor da despesa deve ser maior que zero."
            return false
        }
        errorMessage = nil
        return true
    }
}
