struct CustomerListView: View {
    
    @StateObject private var viewModel = CustomerListViewModel()
    
    // For error handling
    @State private var errorToShow: Error?
    
    // For delete confirmation
    @State private var offsetsToDelete: IndexSet?
    @State private var showDeleteConfirmation = false

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
            .padding([.horizontal, .top])
            
            content
        }
        .navigationTitle("Clientes")
        .task {
            await viewModel.fetchCustomers()
        }
        .onChange(of: viewModel.viewState) { newState in
            if case .error(let error) = newState {
                self.errorToShow = error
            }
        }
        .alert(item: $errorToShow) { error in
            Alert(
                title: Text("Erro"),
                message: Text((error as? LocalizedError)?.errorDescription ?? error.localizedDescription),
                dismissButton: .default(Text("OK"))
            )
        }
        .alert("Confirmar Exclusão", isPresented: $showDeleteConfirmation, presenting: offsetsToDelete) { offsets in
            Button("Apagar", role: .destructive) {
                viewModel.deleteCustomer(at: offsets)
            }
            Button("Cancelar", role: .cancel) {}
        } message: { offsets in
            // This assumes single deletion, which is the default for swipe-to-delete.
            // For multi-select, this message would need to be more generic.
            let customerName = viewModel.filteredCustomers[offsets.first!].name
            Text("Tem certeza que deseja apagar '\(customerName)'? Esta ação não pode ser desfeita.")
        }
    }
    
    @ViewBuilder
    private var content: some View {
        switch viewModel.viewState {
        case .idle, .loading:
            ProgressView("Carregando clientes...")
                .frame(maxHeight: .infinity)
            
        case .success:
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
                .onDelete { offsets in
                    self.offsetsToDelete = offsets
                    self.showDeleteConfirmation = true
                }
            }
            .listStyle(InsetGroupedListStyle())
            
        case .empty:
            Text("Nenhum cliente encontrado.")
                .foregroundColor(.secondary)
                .frame(maxHeight: .infinity)
            
        case .error:
            // The .onChange handler above now manages presenting the error.
            // We can show a generic error view here as a fallback.
            ContentUnavailableView {
                Label("Falha ao Carregar", systemImage: "exclamationmark.triangle")
            } description: {
                Text("Não foi possível carregar os clientes. Tente novamente mais tarde.")
            }
        }
    }
}

// Custom extension to make Error identifiable for the .alert(item:...) modifier
extension Error where Self: LocalizedError, Self: Identifiable {
    public var id: String { localizedDescription }
}

struct IdentifiableError: LocalizedError, Identifiable {
    let id = UUID()
    let error: Error
    var errorDescription: String? {
        (error as? LocalizedError)?.errorDescription ?? error.localizedDescription
    }
}

// Make our ViewState Equatable for .onChange
extension ViewState: Equatable where T: Equatable {
    static func == (lhs: ViewState<T>, rhs: ViewState<T>) -> Bool {
        switch (lhs, rhs) {
        case (.idle, .idle): return true
        case (.loading, .loading): return true
        case (.empty, .empty): return true
        case (.success(let l), .success(let r)): return l == r
        case (.error(let l), .error(let r)): 
            // This comparison is tricky. For UI purposes, we just care if an error occurred.
            // A more robust solution might involve error IDs.
            return l.localizedDescription == r.localizedDescription
        default: return false
        }
    }
}


struct CustomerListView_Previews: PreviewProvider {
    static var previews: some View {
        CustomerListView()
    }
}

