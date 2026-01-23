import SwiftUI

struct RecipeDetailView: View {
    
    @StateObject private var viewModel: RecipeDetailViewModel
    @State private var showAddIngredientSheet = false
    @State private var showErrorAlert = false
    
    init(recipe: Recipe) {
        _viewModel = StateObject(wrappedValue: RecipeDetailViewModel(recipe: recipe))
    }
    
    var body: some View {
        ZStack {
            content
                .navigationTitle("Detalhes da Receita")
                .padding()
                .onAppear {
                    viewModel.fetchData()
                }
                .sheet(isPresented: $showAddIngredientSheet) {
                    AddIngredientView(viewModel: viewModel)
                }
                .alert("Erro", isPresented: $showErrorAlert) {
                    Alert(
                        title: Text("Erro"),
                        message: Text(viewModel.viewState.localizedErrorDescription),
                        dismissButton: .default(Text("OK"))
                    )
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
            ProgressView("Carregando receita...")
        case .success:
            form
        case .empty:
            Text("Receita não encontrada.")
        case .error:
            Text("Ocorreu um erro ao carregar a receita.")
                .onAppear { showErrorAlert = true }
        }
    }
    
    private var form: some View {
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
                Text("Ver Histórico de Versões").foregroundColor(.blue)
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
                Button("Adicionar Ingrediente") {
                    showAddIngredientSheet = true
                }
            }
            
            Section {
                Button(action: { viewModel.saveRecipe() }) {
                    HStack {
                        Spacer()
                        Text("Salvar Receita")
                        Spacer()
                    }
                }
            }
        }
    }
}

// Helper view for the Add Ingredient sheet
struct AddIngredientView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var viewModel: RecipeDetailViewModel
    
    @State private var selectedIngredientType = IngredientType.rawMaterial
    @State private var selectedRawMaterialId: Int64?
    @State private var selectedSubRecipeId: Int64?
    @State private var quantity: Decimal = 1.0
    
    var body: some View {
        NavigationView {
            Form {
                Picker("Tipo de Ingrediente", selection: $selectedIngredientType) {
                    Text("Matéria-Prima").tag(IngredientType.rawMaterial)
                    Text("Sub-receita").tag(IngredientType.subRecipe)
                }
                .pickerStyle(SegmentedPickerStyle())
                
                if selectedIngredientType == .rawMaterial {
                    Picker("Matéria-Prima", selection: $selectedRawMaterialId) {
                        Text("Selecione...").tag(Int64?.none)
                        ForEach(viewModel.allRawMaterials) { material in
                            Text(material.name).tag(material.id as Int64?)
                        }
                    }
                } else {
                    Picker("Sub-receita", selection: $selectedSubRecipeId) {
                        Text("Selecione...").tag(Int64?.none)
                        ForEach(viewModel.allSubRecipes) { recipe in
                            Text(recipe.name).tag(recipe.id as Int64?)
                        }
                    }
                }
                
                DecimalTextField(label: "Quantidade", value: $quantity)
                
                Button("Adicionar") {
                    let id: Int64
                    let name: String
                    if selectedIngredientType == .rawMaterial, let selectedId = selectedRawMaterialId {
                        id = selectedId
                        name = viewModel.allRawMaterials.first { $0.id == id }?.name ?? ""
                    } else if selectedIngredientType == .subRecipe, let selectedId = selectedSubRecipeId {
                        id = selectedId
                        name = viewModel.allSubRecipes.first { $0.id == id }?.name ?? ""
                    } else {
                        return // Nothing selected
                    }
                    
                    viewModel.addIngredient(id: id, type: selectedIngredientType, name: name, quantity: quantity)
                    dismiss()
                }
                .disabled(selectedRawMaterialId == nil && selectedSubRecipeId == nil)
                
            }
            .navigationTitle("Adicionar Ingrediente")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancelar") { dismiss() }
                }
            }
        }
    }
}


struct RecipeDetailView_Previews: PreviewProvider {
    static var previews: some View {
        RecipeDetailView(recipe: Recipe(id: 1, productId: 1, name: "Cobertura de Chocolate", version: 1, totalCost: 8.75, isActive: true))
    }
}
