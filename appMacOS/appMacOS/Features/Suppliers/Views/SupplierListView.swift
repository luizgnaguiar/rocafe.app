import SwiftUI

struct SupplierListView: View {
    
    @StateObject private var viewModel = SupplierListViewModel()
    @State private var showErrorAlert = false
    
    var body: some View {
        VStack {
            HStack {
                TextField("Buscar por nome do fornecedor...", text: $viewModel.searchText)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                
                Spacer()
                
                Button(action: {
                    // TODO: Implement navigation to add supplier view
                }) {
                    Image(systemName: "plus")
                    Text("Novo Fornecedor")
                }
            }
            .padding([.horizontal, .top])
            
            content
        }
        .navigationTitle("Fornecedores")
        .task {
            await viewModel.fetchSuppliers()
        }
        .alert(isPresented: $showErrorAlert) {
            Alert(
                title: Text("Erro"),
                message: Text(viewModel.viewState.localizedErrorDescription),
                dismissButton: .default(Text("OK"))
            )
        }
    }
    
    @ViewBuilder
    private var content: some View {
        switch viewModel.viewState {
        case .idle, .loading:
            ProgressView("Carregando fornecedores...")
                .frame(maxHeight: .infinity)
            
        case .success:
            List {
                ForEach(viewModel.filteredSuppliers) { supplier in
                    // TODO: NavigationLink to SupplierDetailView
                    HStack {
                        VStack(alignment: .leading) {
                            Text(supplier.name)
                                .font(.headline)
                            if let legalName = supplier.legalName {
                                Text(legalName)
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                }
                .onDelete { offsets in
                    Task {
                        await viewModel.deleteSupplier(at: offsets)
                    }
                }
            }
            .listStyle(InsetGroupedListStyle())
            
        case .empty:
            Text("Nenhum fornecedor encontrado.")
                .foregroundColor(.secondary)
                .frame(maxHeight: .infinity)
            
        case .error:
            Color.clear.onAppear {
                showErrorAlert = true
            }
        }
    }
}

struct SupplierListView_Previews: PreviewProvider {
    static var previews: some View {
        SupplierListView()
    }
}
