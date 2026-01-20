import SwiftUI

struct CustomerListView: View {
    
    @StateObject private var viewModel = CustomerListViewModel()
    
    var body: some View {
        VStack {
            HStack {
                TextField("Buscar por nome do cliente...", text: $viewModel.searchText)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                
                Spacer()
                
                Button(action: {
                    // TODO: Implement navigation to add customer view
                }) {
                    Image(systemName: "plus")
                    Text("Novo Cliente")
                }
            }
            .padding()
            
            if viewModel.isLoading {
                ProgressView()
            } else {
                List {
                    ForEach(viewModel.filteredCustomers) { customer in
                        // TODO: NavigationLink to CustomerDetailView
                        HStack {
                            VStack(alignment: .leading) {
                                Text(customer.name)
                                    .font(.headline)
                                if let phone = customer.phone {
                                    Text(phone)
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                }
                            }
                        }
                    }
                    .onDelete(perform: viewModel.deleteCustomer)
                }
            }
        }
        .navigationTitle("Clientes")
        .onAppear {
            viewModel.fetchCustomers()
        }
    }
}

struct CustomerListView_Previews: PreviewProvider {
    static var previews: some View {
        CustomerListView()
    }
}
