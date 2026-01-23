import SwiftUI

struct ProductDetailView: View {
    
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel: ProductDetailViewModel
    
    @State private var showDeleteConfirmation = false
    
    init(product: Product?) {
        _viewModel = StateObject(wrappedValue: ProductDetailViewModel(product: product))
    }
    
    var body: some View {
        ZStack {
            content
                .navigationTitle(viewModel.product.id == nil ? "Novo Produto" : "Editar Produto")
                .padding()
                .disabled(viewModel.viewState == .loading)
                .onAppear {
                    viewModel.fetchRequiredData()
                }
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
                    "Tem certeza que deseja excluir este produto?",
                    isPresented: $showDeleteConfirmation,
                    titleVisibility: .visible
                ) {
                    Button("Excluir Produto", role: .destructive) {
                        viewModel.deleteProduct()
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
        case .idle, .loading:
            ProgressView()
        case .success, .empty: // empty is not really used here, but we show the form
            form
        case .error(let error):
            Text("Erro ao carregar: \(error.localizedDescription)")
        }
    }
    
    private var form: some View {
        Form {
            Section(header: Text("Informações Básicas")) {
                TextField("Nome do Produto", text: $viewModel.product.name)
                Toggle("Produto Ativo", isOn: $viewModel.product.isActive)
                Picker("Tipo de Produto", selection: $viewModel.product.type) {
                    ForEach(ProductType.allCases, id: \.self) { type in
                        Text(type.rawValue).tag(type)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
            }
            
            if viewModel.product.type == .finished {
                productTypeFinishedSection
            }
            
            if viewModel.product.type == .rawMaterial {
                rawMaterialSection
            }
            
            otherInfoSection
            
            if let profitMargin = viewModel.product.profitMargin {
                Section(header: Text("Margem de Lucro")) {
                    Text(profitMargin, format: .percent).font(.headline)
                }
            }
            
            actionButtons
        }
    }
    
    private var productTypeFinishedSection: some View {
        Group {
            Section(header: Text("Tipo de Produto Acabado")) {
                Picker("Categoria", selection: $viewModel.product.category) {
                    Text("Pronto para Revenda").tag(ProductCategory.ready as ProductCategory?)
                    Text("Fabricação Própria").tag(ProductCategory.manufactured as ProductCategory?)
                }
                .pickerStyle(SegmentedPickerStyle())
            }
            
            if viewModel.product.category == .ready {
                Section(header: Text("Preços (Revenda)")) {
                    DecimalTextField(label: "Preço de Compra", value: $viewModel.product.purchasePrice)
                    DecimalTextField(label: "Preço de Venda", value: $viewModel.product.salePrice)
                }
            }
            
            if viewModel.product.category == .manufactured {
                Section(header: Text("Fabricação")) {
                    Picker("Receita", selection: $viewModel.product.recipeId) {
                        Text("Nenhuma").tag(Int64?.none)
                        ForEach(viewModel.allRecipes) { recipe in
                            Text(recipe.name).tag(recipe.id as Int64?)
                        }
                    }
                    HStack {
                        Text("Custo de Fabricação")
                        Spacer()
                        Text(viewModel.product.manufacturingCost ?? 0, format: .currency(code: "BRL"))
                            .foregroundColor(.secondary)
                    }
                    DecimalTextField(label: "Preço de Venda", value: $viewModel.product.salePrice)
                }
            }
        }
    }
    
    private var rawMaterialSection: some View {
        Section(header: Text("Preço (Matéria-Prima)")) {
            DecimalTextField(label: "Preço de Compra", value: $viewModel.product.purchasePrice)
        }
    }
    
    private var otherInfoSection: some View {
        Section(header: Text("Outras Informações")) {
            Picker("Fornecedor (Opcional)", selection: $viewModel.product.supplierId) {
                Text("Nenhum").tag(Int64?.none)
                ForEach(viewModel.allSuppliers) { supplier in
                    Text(supplier.name).tag(supplier.id as Int64?)
                }
            }
        }
    }
    
    private var actionButtons: some View {
        Group {
            Section {
                Button(action: { viewModel.saveProduct() }) {
                    HStack {
                        Spacer()
                        Text("Salvar Produto")
                        Spacer()
                    }
                }
            }
            
            if viewModel.product.id != nil {
                Section {
                    Button(role: .destructive, action: { showDeleteConfirmation = true }) {
                        HStack {
                            Spacer()
                            Text("Excluir Produto")
                            Spacer()
                        }
                    }
                }
            }
        }
    }
}


struct ProductDetailView_Previews: PreviewProvider {
    static var previews: some View {
        ProductDetailView(product: nil)
    }
}
