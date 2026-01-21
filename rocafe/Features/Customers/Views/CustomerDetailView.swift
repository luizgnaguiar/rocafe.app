import SwiftUI

struct CustomerDetailView: View {
    
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel: CustomerDetailViewModel
    
    @State private var showDeleteConfirmation = false
    
    init(customer: Customer) {
        _viewModel = StateObject(wrappedValue: CustomerDetailViewModel(customer: customer))
    }
    
    init(customerId: Int64) {
        _viewModel = StateObject(wrappedValue: CustomerDetailViewModel(customerId: customerId))
    }
    
    var body: some View {
        ZStack {
            content
                .navigationTitle(viewModel.customer.id == nil ? "Novo Cliente" : "Editar Cliente")
                .padding()
                .disabled(viewModel.viewState == .loading)
                .onChange(of: viewModel.viewState) { newState in
                    if case .success(let customer) = newState {
                        // If the view was opened for a specific customer, and that customer is deleted, dismiss the view
                        if showDeleteConfirmation {
                            dismiss()
                        }
                    }
                }
                .alert("Erro", isPresented: Binding(
                    get: { if case .error = viewModel.viewState { return true } else { return false } },
                    set: { _,_ in viewModel.viewState = .idle }
                ), actions: {
                    Button("OK", role: .cancel) { }
                }, message: {
                    if case .error(let error) = viewModel.viewState {
                        Text(error.localizedDescription)
                    }
                })
                .confirmationDialog(
                    "Tem certeza que deseja excluir este cliente?",
                    isPresented: $showDeleteConfirmation,
                    titleVisibility: .visible
                ) {
                    Button("Excluir Cliente", role: .destructive) {
                        viewModel.deleteCustomer()
                    }
                    Button("Cancelar", role: .cancel) {}
                }
            
            // Loading overlay
            if viewModel.viewState == .loading {
                Color.black.opacity(0.4).edgesIgnoringSafeArea(.all)
                ProgressView("Processando...").padding().background(Color.white).cornerRadius(10)
            }
        }
    }
    
    @ViewBuilder
    private var content: some View {
        switch viewModel.viewState {
        case .idle, .success:
            form
        case .loading:
            form.disabled(true)
        case .empty:
            Text("Cliente não encontrado.")
        case .error(let error):
            Text("Erro ao carregar o cliente: \(error.localizedDescription)")
        }
    }
    
    private var form: some View {
        Form {
            Section(header: Text("Informações Pessoais")) {
                TextField("Nome Completo", text: $viewModel.customer.name)
                TextField("CPF (Opcional)", text: Binding(
                    get: { viewModel.customer.cpf ?? "" },
                    set: { viewModel.customer.cpf = $0 }
                ))
            }
            
            Section(header: Text("Contato")) {
                TextField("Telefone (Opcional)", text: Binding(
                    get: { viewModel.customer.phone ?? "" },
                    set: { viewModel.customer.phone = $0 }
                ))
                TextField("Email (Opcional)", text: Binding(
                    get: { viewModel.customer.email ?? "" },
                    set: { viewModel.customer.email = $0 }
                ))
            }
            
            Section(header: Text("Endereço")) {
                TextField("Endereço (Opcional)", text: Binding(
                    get: { viewModel.customer.address ?? "" },
                    set: { viewModel.customer.address = $0 }
                ))
                TextField("Cidade (Opcional)", text: Binding(
                    get: { viewModel.customer.city ?? "" },
                    set: { viewModel.customer.city = $0 }
                ))
            }
            
            Section(header: Text("Observações")) {
                TextEditor(text: Binding(
                    get: { viewModel.customer.notes ?? "" },
                    set: { viewModel.customer.notes = $0 }
                ))
                .frame(height: 100)
            }
            
            Section {
                Toggle("Cliente Ativo", isOn: $viewModel.customer.isActive)
            }
            
            Section {
                Button(action: {
                    viewModel.saveCustomer()
                }) {
                    HStack {
                        Spacer()
                        Text("Salvar Cliente")
                        Spacer()
                    }
                }
            }
            
            if viewModel.customer.id != nil {
                Section {
                    Button(role: .destructive, action: {
                        showDeleteConfirmation = true
                    }) {
                        HStack {
                            Spacer()
                            Text("Excluir Cliente")
                            Spacer()
                        }
                    }
                }
            }
        }
    }
}


struct CustomerDetailView_Previews: PreviewProvider {
    static var previews: some View {
        CustomerDetailView(customer: Customer(id: 1, name: "Preview Customer", isActive: true))
    }
}
