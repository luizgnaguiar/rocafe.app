import SwiftUI

struct ProductListView: View {
    
    @StateObject private var viewModel = ProductListViewModel()
    
    // For error handling
    @State private var errorToShow: IdentifiableError?
    
    // For delete confirmation
    @State private var offsetsToDelete: IndexSet?
    
    var body: some View {
        VStack {
            HStack {
                TextField("Buscar por nome...", text: $viewModel.searchText)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .frame(minWidth: 200)
                
                Picker("Tipo", selection: $viewModel.productTypeFilter) {
                    Text("Todos").tag(ProductType?.none)
                    ForEach(ProductType.allCases, id: \.self) { type in
                        Text(type.rawValue).tag(ProductType?.some(type))
                    }
                }
                .frame(width: 180)
                
                Spacer()
                
                Button(action: {
                    // TODO: Implement navigation to add product view
                }) {
                    Image(systemName: "plus")
                    Text("Novo Produto")
                }
            }
            .padding([.horizontal, .top])
            
            content
        }
        .navigationTitle("Produtos")
        .task {
            await viewModel.fetchProducts()
        }
        .onChange(of: viewModel.viewState) {
            if case .error(let error) = viewModel.viewState {
                self.errorToShow = IdentifiableError(error: error)
            }
        }
        .alert(item: $errorToShow) { error in
            Alert(
                title: Text("Erro"),
                message: Text(error.errorDescription ?? "Ocorreu um erro desconhecido."),
                dismissButton: .default(Text("OK"))
            )
        }
        .confirmationDialog("Confirmar Exclusão", isPresented: Binding(
            get: { offsetsToDelete != nil },
            set: { if !$0 { offsetsToDelete = nil } }
        ), presenting: offsetsToDelete) { offsets in
            Button("Apagar Produto", role: .destructive) {
                Task {
                    await viewModel.deleteProduct(at: offsets)
                }
            }
            Button("Cancelar", role: .cancel) {}
        } message: { offsets in
            let productName = viewModel.filteredProducts[offsets.first!].name
            Text("Tem certeza que deseja apagar '\(productName)'? Esta ação não pode ser desfeita.")
        }
    }
    
    @ViewBuilder
    private var content: some View {
        switch viewModel.viewState {
        case .idle, .loading:
            ProgressView("Carregando produtos...")
                .frame(maxHeight: .infinity)
            
        case .success:
            List {
                ForEach(viewModel.filteredProducts) { product in
                    // TODO: NavigationLink to ProductDetailView
                    HStack {
                        VStack(alignment: .leading) {
                            Text(product.name)
                                .font(.headline)
                            Text(product.type.rawValue)
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        Spacer()
                        if let salePrice = product.salePrice {
                            Text(salePrice, format: .currency(code: "BRL"))
                        } else if let purchasePrice = product.purchasePrice {
                            Text(purchasePrice, format: .currency(code: "BRL"))
                        }
                    }
                }
                .onDelete { offsets in
                    self.offsetsToDelete = offsets
                }
            }
            .listStyle(InsetGroupedListStyle())
            
        case .empty:
            Text("Nenhum produto encontrado.")
                .foregroundColor(.secondary)
                .frame(maxHeight: .infinity)
            
        case .error:
            ContentUnavailableView {
                Label("Falha ao Carregar", systemImage: "exclamationmark.triangle")
            } description: {
                Text("Não foi possível carregar os produtos. Tente novamente mais tarde.")
            }
        }
    }
}

// NOTE: The IdentifiableError struct and Equatable extension for ViewState
// should be moved to a shared file to be reused across views.
// For now, they are assumed to be available from the CustomerListView context.

struct ProductListView_Previews: PreviewProvider {
    static var previews: some View {
        ProductListView()
    }
}
