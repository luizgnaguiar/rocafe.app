import Foundation
import Combine

@MainActor
class ExpenseDetailViewModel: ObservableObject {
    
    @Published var expense: Expense
    @Published var viewState: ViewState<Expense> = .idle
    
    // For pickers
    @Published var allSuppliers: [Supplier] = []
    
    private let expenseService: ExpenseService
    private let supplierRepo: SupplierRepository
    
    init(
        expense: Expense?,
        expenseService: ExpenseService = ExpenseService(),
        supplierRepo: SupplierRepository = SupplierRepositoryImpl()
    ) {
        self.expense = expense ?? Expense(id: nil, description: "", category: .contas, amount: 0, dueDate: Date(), isPaid: false, wasAdjusted: false)
        self.expenseService = expenseService
        self.supplierRepo = supplierRepo
    }
    
    func onAppear() {
        Task {
            do {
                self.allSuppliers = try supplierRepo.getAll()
            } catch {
                // Handle error silently or log it
                print("Error fetching suppliers: \(error)")
            }
        }
    }
    
    func saveExpense() {
        viewState = .loading
        
        Task {
            do {
                var expenseToSave = self.expense
                try expenseService.save(expense: &expenseToSave)
                self.expense = expenseToSave // Update the view model with the saved (potentially modified) expense
                viewState = .success(expenseToSave)
            } catch {
                // Now we catch a specific, typed error from the service layer.
                viewState = .error(error)
            }
        }
    }
}
