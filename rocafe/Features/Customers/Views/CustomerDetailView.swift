import SwiftUI

struct CustomerDetailView: View {
    
    @StateObject private var viewModel: CustomerDetailViewModel
    
    init(customer: Customer?) {
        _viewModel = StateObject(wrappedValue: CustomerDetailViewModel(customer: customer))
    }
    
    var body: some View {
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
            
            if let errorMessage = viewModel.errorMessage {
                Section {
                    Text(errorMessage).foregroundColor(.red)
                }
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
                .disabled(viewModel.isLoading)
            }
        }
        .navigationTitle(viewModel.customer.id == nil ? "Novo Cliente" : "Editar Cliente")
        .padding()
    }
}

struct CustomerDetailView_Previews: PreviewProvider {
    static var previews: some View {
        CustomerDetailView(customer: nil)
    }
}
