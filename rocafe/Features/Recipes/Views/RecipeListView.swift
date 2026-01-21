import SwiftUI

struct RecipeListView: View {
    
    @StateObject private var viewModel = RecipeListViewModel()
    @State private var showErrorAlert = false
    
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
        .onAppear {
            viewModel.fetchRecipes()
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
                .onDelete(perform: viewModel.deleteRecipe)
            }
            .listStyle(InsetGroupedListStyle())
            
        case .empty:
            Text("Nenhuma receita encontrada.")
                .foregroundColor(.secondary)
                .frame(maxHeight: .infinity)
            
        case .error:
            Color.clear.onAppear {
                showErrorAlert = true
            }
        }
    }
}

struct RecipeListView_Previews: PreviewProvider {
    static var previews: some View {
        RecipeListView()
    }
}
