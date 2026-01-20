import SwiftUI

struct RecipeListView: View {
    
    @StateObject private var viewModel = RecipeListViewModel()
    
    var body: some View {
        VStack {
            // Header with Search
            HStack {
                TextField("Buscar por nome da receita...", text: $viewModel.searchText)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                
                Spacer()
                
                // Note: A recipe is implicitly created when a "Manufactured"
                // product is created. We might not need a "New Recipe" button here,
                // as the workflow is tied to the product.
            }
            .padding()
            
            // Recipe List
            if viewModel.isLoading {
                ProgressView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
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
            }
        }
        .navigationTitle("Receitas")
        .onAppear {
            viewModel.fetchRecipes()
        }
    }
}

struct RecipeListView_Previews: PreviewProvider {
    static var previews: some View {
        RecipeListView()
    }
}
