import SwiftUI

struct RecipeListView: View {
    
    @StateObject private var viewModel = RecipeListViewModel()
    
    // For error handling
    @State private var errorToShow: IdentifiableError?
    
    // For delete confirmation
    @State private var offsetsToDelete: IndexSet?
    
    var body: some View {
        VStack {
            HStack {
                TextField("Buscar por nome da receita...", text: $viewModel.searchText)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                
                Spacer()
                
                // Note: The workflow for creating a recipe is tied to creating a "Manufactured" product.
            }
            .padding([.horizontal, .top])
            
            content
        }
        .navigationTitle("Receitas")
        .task {
            await viewModel.fetchRecipes()
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
            Button("Apagar Receita", role: .destructive) {
                Task {
                    await viewModel.deleteRecipe(at: offsets)
                }
            }
            Button("Cancelar", role: .cancel) {}
        } message: { offsets in
            let recipeName = viewModel.filteredRecipes[offsets.first!].name
            Text("Tem certeza que deseja apagar '\(recipeName)'? Esta ação não pode ser desfeita.")
        }
    }
    
    @ViewBuilder
    private var content: some View {
        switch viewModel.viewState {
        case .idle, .loading:
            ProgressView("Carregando receitas...")
                .frame(maxHeight: .infinity)
            
        case .success:
            List {
                ForEach(viewModel.filteredRecipes) { recipe in
                    // TODO: NavigationLink to RecipeDetailView
                    HStack {
                        VStack(alignment: .leading) {
                            Text(recipe.name)
                                .font(.headline)
                            Text("Versão \(recipe.version)")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        Spacer()
                        Text(recipe.totalCost, format: .currency(code: "BRL"))
                    }
                }
                .onDelete { offsets in
                    self.offsetsToDelete = offsets
                }
            }
            .listStyle(InsetGroupedListStyle())
            
        case .empty:
            Text("Nenhuma receita encontrada.")
                .foregroundColor(.secondary)
                .frame(maxHeight: .infinity)
            
        case .error:
            ContentUnavailableView {
                Label("Falha ao Carregar", systemImage: "exclamationmark.triangle")
            } description: {
                Text("Não foi possível carregar as receitas. Tente novamente mais tarde.")
            }
        }
    }
}

struct RecipeListView_Previews: PreviewProvider {
    static var previews: some View {
        RecipeListView()
    }
}