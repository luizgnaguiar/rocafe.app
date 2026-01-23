import SwiftUI

struct RecipeVersionHistoryView: View {
    
    let recipeId: Int64
    
    // TODO: This view needs a ViewModel to fetch the RecipeVersion records
    // for the given recipeId.
    
    var body: some View {
        VStack {
            Text("Histórico de Versões da Receita")
                .font(.largeTitle)
                .padding()
            
            // This would be a List of RecipeVersion entries
            List {
                // Example of a version entry
                VStack(alignment: .leading) {
                    Text("Versão 2")
                        .font(.headline)
                    Text("Modificado em: 01/01/2025 10:30")
                        .font(.subheadline)
                    Text("Descrição da mudança: Aumentou a quantidade de açúcar.")
                        .padding(.top, 2)
                    
                    // In a real implementation, you would have a button here
                    // to show the JSON snapshot data in a readable format.
                    Text("Ver Detalhes do Snapshot...")
                        .foregroundColor(.blue)
                        .padding(.top, 5)
                }
                .padding(.vertical)
            }
        }
        .navigationTitle("Histórico da Receita")
        .onAppear {
            // TODO: Fetch version history from ViewModel
        }
    }
}

struct RecipeVersionHistoryView_Previews: PreviewProvider {
    static var previews: some View {
        RecipeVersionHistoryView(recipeId: 1)
    }
}
