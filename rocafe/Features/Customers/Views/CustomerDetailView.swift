import SwiftUI

struct CustomerDetailView: View {
    
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel: CustomerDetailViewModel
    
    @State private var showDeleteConfirmation = false
    @State private var viewState: ViewState<Customer> = .idle
    
    init(customer: Customer?) {
        _viewModel = StateObject(wrappedValue: CustomerDetailViewModel(customer: customer))
    }
    
    var body: some View {
        ZStack {
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
                    // Add State and ZipCode fields if needed
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
                
                // Add a delete button only for existing customers
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
            .navigationTitle(viewModel.customer.id == nil ? "Novo Cliente" : "Editar Cliente")
            .padding()
            .disabled(viewState == .loading)
            .onChange(of: viewModel.viewState) { newState in
                self.viewState = newState
                
                // If deletion was successful, dismiss the view
                if case .success(let customer) = newState, customer.id == viewModel.customer.id, showDeleteConfirmation {
                    dismiss()
                }
            }
            .alert("Erro", isPresented: Binding(
                get: { if case .error = viewState { return true } else { return false } },
                set: { _,_ in viewState = .idle }
            ), actions: {
                Button("OK", role: .cancel) { }
            }, message: {
                if case .error(let error) = viewState {
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
            if viewState == .loading {
                Color.black.opacity(0.4).edgesIgnoringSafeArea(.all)
                ProgressView("Processando...").padding().background(Color.white).cornerRadius(10)
            }
        }
    }
}


struct CustomerDetailView_Previews: PreviewProvider {
    static var previews: some View {
        CustomerDetailView(customer: Customer(id: 1, name: "Preview Customer", isActive: true))
    }
}
