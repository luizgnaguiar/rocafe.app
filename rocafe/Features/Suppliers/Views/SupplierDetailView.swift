import SwiftUI

struct SupplierDetailView: View {
    
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel: SupplierDetailViewModel
    
    @State private var showDeleteConfirmation = false
    
    init(supplier: Supplier) {
        _viewModel = StateObject(wrappedValue: SupplierDetailViewModel(supplier: supplier))
    }
    
    init(supplierId: Int64) {
        _viewModel = StateObject(wrappedValue: SupplierDetailViewModel(supplierId: supplierId))
    }
    
    var body: some View {
        ZStack {
            content
                .navigationTitle(viewModel.supplier.id == nil ? "Novo Fornecedor" : "Editar Fornecedor")
                .padding()
                .disabled(viewModel.viewState == .loading)
                .onChange(of: viewModel.viewState) { newState in
                    if case .success = newState, showDeleteConfirmation {
                        dismiss()
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
                    "Tem certeza que deseja excluir este fornecedor?",
                    isPresented: $showDeleteConfirmation,
                    titleVisibility: .visible
                ) {
                    Button("Excluir Fornecedor", role: .destructive) {
                        viewModel.deleteSupplier()
                    }
                    Button("Cancelar", role: .cancel) {}
                }
            
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
            Text("Fornecedor não encontrado.")
        case .error(let error):
            Text("Erro ao carregar o fornecedor: \(error.localizedDescription)")
        }
    }
    
    private var form: some View {
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
            }
            
            Section {
                Toggle("Fornecedor Ativo", isOn: $viewModel.supplier.isActive)
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
            }
            
            if viewModel.supplier.id != nil {
                Section {
                    Button(role: .destructive, action: {
                        showDeleteConfirmation = true
                    }) {
                        HStack {
                            Spacer()
                            Text("Excluir Fornecedor")
                            Spacer()
                        }
                    }
                }
            }
        }
    }
}

struct SupplierDetailView_Previews: PreviewProvider {
    static var previews: some View {
        SupplierDetailView(supplier: Supplier(id: 1, name: "Preview Supplier", isActive: true))
    }
}
