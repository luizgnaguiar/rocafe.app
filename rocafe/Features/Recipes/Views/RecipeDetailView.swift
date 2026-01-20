import SwiftUI

struct RecipeDetailView: View {
    
    @StateObject private var viewModel: RecipeDetailViewModel
    
    init(recipe: Recipe) {
        _viewModel = StateObject(wrappedValue: RecipeDetailViewModel(recipe: recipe))
    }
    
    var body: some View {
        Form {
            Section(header: Text("Informações da Receita")) {
                HStack {
                    Text("Nome")
                    Spacer()
                    TextField("Nome", text: $viewModel.recipe.name)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                }
                Toggle("Receita Ativa", isOn: $viewModel.recipe.isActive)
                HStack {
                    Text("Custo Total")
                    Spacer()
                    Text(viewModel.recipe.totalCost, format: .currency(code: "BRL"))
                }
                HStack {
                    Text("Versão Atual")
                    Spacer()
                    Text("\(viewModel.recipe.version)")
                }
                // TODO: NavigationLink to RecipeVersionHistoryView
                Text("Ver Histórico de Versões")
                    .foregroundColor(.blue)
            }
            
            Section(header: Text("Ingredientes")) {
                List {
                    ForEach(viewModel.ingredients) { item in
                        HStack {
                            Text(item.name)
                            Spacer()
                            Text("\(item.quantity, format: .number) unidades")
                        }
                    }
                    .onDelete(perform: viewModel.removeIngredient)
                }
                // TODO: Add UI for adding a new ingredient
                // This would likely involve a sheet or a separate view with pickers
                // for raw materials and sub-recipes.
                Button("Adicionar Ingrediente") {
                    // Show a sheet to add ingredient
                }
            }
            
            if let errorMessage = viewModel.errorMessage {
                Section {
                    Text(errorMessage).foregroundColor(.red)
                }
            }
            
            Section {
                Button(action: {
                    viewModel.saveRecipe()
                }) {
                    HStack {
                        Spacer()
                        Text("Salvar Receita")
                        Spacer()
                    }
                }
                .disabled(viewModel.isLoading)
            }
        }
        .navigationTitle("Detalhes da Receita")
        .padding()
        .onAppear {
            viewModel.onAppear()
        }
    }
}

struct RecipeDetailView_Previews: PreviewProvider {
    static var previews: some View {
        // A recipe needs a product, so this setup is a bit complex for a preview.
        // We'll use a placeholder.
        RecipeDetailView(recipe: Recipe(id: 1, productId: 1, name: "Cobertura de Chocolate", version: 1, totalCost: 8.75, isActive: true))
    }
}
