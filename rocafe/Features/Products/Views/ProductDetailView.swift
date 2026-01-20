import SwiftUI

struct ProductDetailView: View {
    
    @StateObject private var viewModel: ProductDetailViewModel
    
    // TODO: Use a proper decimal formatter
    private var numberFormatter: NumberFormatter = {
        let f = NumberFormatter()
        f.numberStyle = .decimal
        f.minimumFractionDigits = 2
        f.maximumFractionDigits = 2
        return f
    }()
    
    init(product: Product?) {
        _viewModel = StateObject(wrappedValue: ProductDetailViewModel(product: product))
    }
    
    var body: some View {
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
            
            // Fields shown for Finished Products
            if viewModel.product.type == .finished {
                Section(header: Text("Tipo de Produto Acabado")) {
                    Picker("Categoria", selection: $viewModel.product.category) {
                        Text("Pronto para Revenda").tag(ProductCategory.ready as ProductCategory?)
                        Text("Fabricação Própria").tag(ProductCategory.manufactured as ProductCategory?)
                    }
                    .pickerStyle(SegmentedPickerStyle())
                }
                
                // Fields for "Ready for Resale"
                if viewModel.product.category == .ready {
                    Section(header: Text("Preços (Revenda)")) {
                        HStack {
                            Text("Preço de Compra")
                            Spacer()
                            TextField("Valor", value: $viewModel.product.purchasePrice, formatter: numberFormatter)
                                .textFieldStyle(RoundedBorderTextFieldStyle()).frame(width: 120)
                        }
                        HStack {
                            Text("Preço de Venda")
                            Spacer()
                            TextField("Valor", value: $viewModel.product.salePrice, formatter: numberFormatter)
                                .textFieldStyle(RoundedBorderTextFieldStyle()).frame(width: 120)
                        }
                    }
                }
                
                // Fields for "Manufactured"
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
                        HStack {
                            Text("Preço de Venda")
                            Spacer()
                            TextField("Valor", value: $viewModel.product.salePrice, formatter: numberFormatter)
                                .textFieldStyle(RoundedBorderTextFieldStyle()).frame(width: 120)
                        }
                    }
                }
            }
            
            // Fields for Raw Materials
            if viewModel.product.type == .rawMaterial {
                Section(header: Text("Preço (Matéria-Prima)")) {
                    HStack {
                        Text("Preço de Compra")
                        Spacer()
                        TextField("Valor", value: $viewModel.product.purchasePrice, formatter: numberFormatter)
                            .textFieldStyle(RoundedBorderTextFieldStyle()).frame(width: 120)
                    }
                }
            }
            
            // Common Fields
            Section(header: Text("Outras Informações")) {
                Picker("Fornecedor (Opcional)", selection: $viewModel.product.supplierId) {
                    Text("Nenhum").tag(Int64?.none)
                    ForEach(viewModel.allSuppliers) { supplier in
                        Text(supplier.name).tag(supplier.id as Int64?)
                    }
                }
            }
            
            if let profitMargin = viewModel.product.profitMargin {
                Section(header: Text("Margem de Lucro")) {
                    Text(profitMargin, format: .percent)
                        .font(.headline)
                }
            }
            
            if let errorMessage = viewModel.errorMessage {
                Section {
                    Text(errorMessage).foregroundColor(.red)
                }
            }
            
            Section {
                Button(action: {
                    viewModel.saveProduct()
                }) {
                    HStack {
                        Spacer()
                        Text("Salvar Produto")
                        Spacer()
                    }
                }
                .disabled(viewModel.isLoading)
            }
        }
        .navigationTitle(viewModel.product.id == nil ? "Novo Produto" : "Editar Produto")
        .padding()
        .onAppear {
            viewModel.onAppear()
        }
    }
}

struct ProductDetailView_Previews: PreviewProvider {
    static var previews: some View {
        // Preview for a new product
        ProductDetailView(product: nil)
        
        // Preview for an existing manufactured product
        ProductDetailView(product: Product(id: 1, name: "Bolo de Chocolate", type: .finished, category: .manufactured, manufacturingCost: 15.50, salePrice: 35.0, isActive: true))
    }
}
