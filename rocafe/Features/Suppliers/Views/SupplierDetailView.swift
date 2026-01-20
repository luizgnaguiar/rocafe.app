import SwiftUI

struct SupplierDetailView: View {
    
    @StateObject private var viewModel: SupplierDetailViewModel
    
    init(supplier: Supplier?) {
        _viewModel = StateObject(wrappedValue: SupplierDetailViewModel(supplier: supplier))
    }
    
    var body: some View {
        Form {
            Section(header: Text("Informações do Fornecedor")) {
                TextField("Nome Fantasia", text: $viewModel.supplier.name)
                TextField("Razão Social (Opcional)", text: Binding(
                    get: { viewModel.supplier.legalName ?? "" },
                    set: { viewModel.supplier.legalName = $0 }
                ))
                TextField("CNPJ (Opcional)", text: Binding(
                    get: { viewModel.supplier.cnpj ?? "" },
                    set: { viewModel.supplier.cnpj = $0 }
                ))
            }
            
            Section(header: Text("Contato")) {
                TextField("Telefone (Opcional)", text: Binding(
                    get: { viewModel.supplier.phone ?? "" },
                    set: { viewModel.supplier.phone = $0 }
                ))
                TextField("Email (Opcional)", text: Binding(
                    get: { viewModel.supplier.email ?? "" },
                    set: { viewModel.supplier.email = $0 }
                ))
            }
            
            Section(header: Text("Endereço")) {
                TextField("Endereço (Opcional)", text: Binding(
                    get: { viewModel.supplier.address ?? "" },
                    set: { viewModel.supplier.address = $0 }
                ))
                // Add other address fields if needed
            }
            
            Section {
                Toggle("Fornecedor Ativo", isOn: $viewModel.supplier.isActive)
            }
            
            if let errorMessage = viewModel.errorMessage {
                Section {
                    Text(errorMessage).foregroundColor(.red)
                }
            }
            
            Section {
                Button(action: {
                    viewModel.saveSupplier()
                }) {
                    HStack {
                        Spacer()
                        Text("Salvar Fornecedor")
                        Spacer()
                    }
                }
                .disabled(viewModel.isLoading)
            }
        }
        .navigationTitle(viewModel.supplier.id == nil ? "Novo Fornecedor" : "Editar Fornecedor")
        .padding()
    }
}

struct SupplierDetailView_Previews: PreviewProvider {
    static var previews: some View {
        SupplierDetailView(supplier: nil)
    }
}
