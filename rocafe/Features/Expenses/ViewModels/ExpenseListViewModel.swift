import Foundation
import Combine

@MainActor
class ExpenseListViewModel: ObservableObject {
    
    @Published var allExpenses: [Expense] = []
    @Published var filteredExpenses: [Expense] = []
    
    @Published var searchText: String = ""
    @Published var categoryFilter: ExpenseCategory? = nil
    
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let repository: ExpenseRepository
    private var cancellables = Set<AnyCancellable>()
    
    init(repository: ExpenseRepository = ExpenseRepositoryImpl()) {
        self.repository = repository
        
        $searchText
            .combineLatest($categoryFilter, $allExpenses)
            .debounce(for: .milliseconds(300), scheduler: RunLoop.main)
            .map { (text, category, expenses) -> [Expense] in
                var filtered = expenses
                
                if let category = category {
                    filtered = filtered.filter { $0.category == category }
                }
                
                if !text.isEmpty {
                    let lowercasedText = text.lowercased()
                    filtered = filtered.filter { $0.description.lowercased().contains(lowercasedText) }
                }
                
                return filtered
            }
            .assign(to: \.filteredExpenses, on: self)
            .store(in: &cancellables)
    }
    
    func fetchExpenses() {
        isLoading = true
        errorMessage = nil
        
        self.allExpenses = repository.getAll()
        
        isLoading = false
    }
    
    func deleteExpense(at offsets: IndexSet) {
        let expensesToDelete = offsets.map { filteredExpenses[$0] }
        
        expensesToDelete.forEach { expense in
            guard let expenseId = expense.id else { return }
            if repository.delete(id: expenseId) {
                allExpenses.removeAll { $0.id == expenseId }
            }
        }
    }
}
