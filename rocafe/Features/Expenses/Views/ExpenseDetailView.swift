import SwiftUI

struct ExpenseDetailView: View {
    
    @StateObject private var viewModel: ExpenseDetailViewModel
    @State private var showErrorAlert = false
    
    // TODO: Use a proper decimal formatter
    private var numberFormatter: NumberFormatter = {
        let f = NumberFormatter()
        f.numberStyle = .decimal
        f.minimumFractionDigits = 2
        f.maximumFractionDigits = 2
        return f
    }()
    
    init(expense: Expense?) {
        _viewModel = StateObject(wrappedValue: ExpenseDetailViewModel(expense: expense))
    }
    
    var body: some View {
        ZStack {
            Form {
                Section(header: Text("Detalhes da Despesa")) {
                    TextField("Descrição", text: $viewModel.expense.description)
                    
                    HStack {
                        Text("Valor")
                        Spacer()
                        TextField("Valor", value: $viewModel.expense.amount, formatter: numberFormatter)
                            .textFieldStyle(RoundedBorderTextFieldStyle()).frame(width: 120)
                    }
                    
                    Picker("Categoria", selection: $viewModel.expense.category) {
                        ForEach(ExpenseCategory.allCases) { category in
                            Text(category.rawValue).tag(category)
                        }
                    }
                }
                
                Section(header: Text("Datas e Status")) {
                    DatePicker("Data de Vencimento", selection: $viewModel.expense.dueDate, displayedComponents: .date)
                    
                    Toggle("Despesa Paga?", isOn: $viewModel.expense.isPaid)
                    
                    if viewModel.expense.isPaid {
                        DatePicker("Data de Pagamento", selection: Binding(
                            get: { viewModel.expense.paymentDate ?? Date() },
                            set: { viewModel.expense.paymentDate = $0 }
                        ), displayedComponents: .date)
                    }
                }
                
                Section(header: Text("Outras Informações")) {
                    Picker("Fornecedor (Opcional)", selection: $viewModel.expense.supplierId) {
                        Text("Nenhum").tag(Int64?.none)
                        ForEach(viewModel.allSuppliers) { supplier in
                            Text(supplier.name).tag(supplier.id as Int64?)
                        }
                    }
                    TextField("Notas (Opcional)", text: Binding(
                        get: { viewModel.expense.notes ?? ""},
                        set: { viewModel.expense.notes = $0 }
                    ))
                }
                
                Section {
                    Button(action: {
                        viewModel.saveExpense()
                    }) {
                        HStack {
                            Spacer()
                            Text("Salvar Despesa")
                            Spacer()
                        }
                    }
                }
            }
            .navigationTitle(viewModel.expense.id == nil ? "Nova Despesa" : "Editar Despesa")
            .padding()
            .onAppear {
                viewModel.onAppear()
            }
            .onChange(of: viewModel.viewState) { newState in
                if case .error = newState {
                    showErrorAlert = true
                }
            }
            .alert("Erro", isPresented: $showErrorAlert, actions: {
                Button("OK", role: .cancel) { }
            }, message: {
                if case .error(let error) = viewModel.viewState {
                    Text(error.localizedDescription)
                }
            })

            // Loading overlay
            if case .loading = viewModel.viewState {
                Color.black.opacity(0.4)
                    .edgesIgnoringSafeArea(.all)
                ProgressView("Salvando...")
                    .progressViewStyle(CircularProgressViewStyle())
                    .padding()
                    .background(Color.white)
                    .cornerRadius(10)
            }
        }
    }
}

struct ExpenseDetailView_Previews: PreviewProvider {
    static var previews: some View {
        ExpenseDetailView(expense: nil)
    }
}
