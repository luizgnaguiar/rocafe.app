import SwiftUI

struct ExpenseListView: View {
    
    @StateObject private var viewModel = ExpenseListViewModel()
    
    var body: some View {
        VStack {
            HStack {
                TextField("Buscar por descrição...", text: $viewModel.searchText)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                
                Picker("Categoria", selection: $viewModel.categoryFilter) {
                    Text("Todas").tag(ExpenseCategory?.none)
                    ForEach(ExpenseCategory.allCases) { category in
                        Text(category.rawValue).tag(category as ExpenseCategory?)
                    }
                }
                .frame(width: 200)
                
                Spacer()
                
                Button(action: {
                    // TODO: Implement navigation to add expense view
                }) {
                    Image(systemName: "plus")
                    Text("Nova Despesa")
                }
            }
            .padding()
            
            if viewModel.isLoading {
                ProgressView()
            } else {
                List {
                    ForEach(viewModel.filteredExpenses) { expense in
                        // TODO: NavigationLink to ExpenseDetailView
                        HStack {
                            VStack(alignment: .leading) {
                                Text(expense.description)
                                    .font(.headline)
                                Text(expense.category.rawValue)
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                            Spacer()
                            VStack(alignment: .trailing) {
                                Text(expense.amount, format: .currency(code: "BRL"))
                                Text(expense.dueDate, style: .date)
                                    .font(.caption)
                                    .foregroundColor(expense.isPaid ? .green : .red)
                            }
                        }
                    }
                    .onDelete(perform: viewModel.deleteExpense)
                }
            }
        }
        .navigationTitle("Despesas")
        .onAppear {
            viewModel.fetchExpenses()
        }
    }
}

struct ExpenseListView_Previews: PreviewProvider {
    static var previews: some View {
        ExpenseListView()
    }
}
