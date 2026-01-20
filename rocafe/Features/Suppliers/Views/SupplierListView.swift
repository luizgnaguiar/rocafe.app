import SwiftUI

struct SupplierListView: View {
    
    @StateObject private var viewModel = SupplierListViewModel()
    
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
            .padding()
            
            if viewModel.isLoading {
                ProgressView()
            } else {
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
                    .onDelete(perform: viewModel.deleteSupplier)
                }
            }
        }
        .navigationTitle("Fornecedores")
        .onAppear {
            viewModel.fetchSuppliers()
        }
    }
}

struct SupplierListView_Previews: PreviewProvider {
    static var previews: some View {
        SupplierListView()
    }
}
