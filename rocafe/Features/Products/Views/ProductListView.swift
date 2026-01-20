import SwiftUI

struct ProductListView: View {
    
    @StateObject private var viewModel = ProductListViewModel()
    
    var body: some View {
        VStack {
            // Header with Filters and Search
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
            .padding()
            
            // Product List
            if viewModel.isLoading {
                ProgressView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
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
                            // Display a relevant price
                            if let salePrice = product.salePrice {
                                Text(salePrice, format: .currency(code: "BRL"))
                            } else if let purchasePrice = product.purchasePrice {
                                Text(purchasePrice, format: .currency(code: "BRL"))
                            }
                        }
                    }
                    .onDelete(perform: viewModel.deleteProduct)
                }
            }
        }
        .navigationTitle("Produtos")
        .onAppear {
            viewModel.fetchProducts()
        }
    }
}

struct ProductListView_Previews: PreviewProvider {
    static var previews: some View {
        ProductListView()
    }
}
