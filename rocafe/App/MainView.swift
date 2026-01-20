import SwiftUI

struct MainView: View {
    
    private enum NavigationItem {
        case dashboard
        case dailyEntry
        case products
        case recipes
        case suppliers
        case customers
        case expenses
        case reports
    }
    
    @State private var selection: NavigationItem? = .dashboard
    
    var body: some View {
        NavigationView {
            List {
                Section(header: Text("Menu")) {
                    NavigationLink(tag: NavigationItem.dashboard, selection: $selection) {
                        // TODO: Create a DashboardView
                        Text("Dashboard (placeholder)")
                    } label: {
                        Label("Dashboard", systemImage: "chart.pie.fill")
                    }
                    
                    NavigationLink(tag: NavigationItem.dailyEntry, selection: $selection) {
                        DailyEntryFormView()
                    } label: {
                        Label("Lançamento Diário", systemImage: "calendar")
                    }
                }
                
                Section(header: Text("Cadastros")) {
                    NavigationLink(tag: NavigationItem.products, selection: $selection) {
                        ProductListView()
                    } label: {
                        Label("Produtos", systemImage: "tag.fill")
                    }
                    
                    NavigationLink(tag: NavigationItem.recipes, selection: $selection) {
                        RecipeListView()
                    } label: {
                        Label("Receitas", systemImage: "book.fill")
                    }
                    
                    NavigationLink(tag: NavigationItem.suppliers, selection: $selection) {
                        SupplierListView()
                    } label: {
                        Label("Fornecedores", systemImage: "truck.box.fill")
                    }
                    
                    NavigationLink(tag: NavigationItem.customers, selection: $selection) {
                        CustomerListView()
                    } label: {
                        Label("Clientes", systemImage: "person.2.fill")
                    }
                }
                
                Section(header: Text("Financeiro")) {
                    NavigationLink(tag: NavigationItem.expenses, selection: $selection) {
                        ExpenseListView()
                    } label: {
                        Label("Despesas", systemImage: "cart.fill")
                    }
                    
                    NavigationLink(tag: NavigationItem.reports, selection: $selection) {
                        ReportView()
                    } label: {
                        Label("Relatórios", systemImage: "chart.bar.xaxis")
                    }
                }
            }
            .listStyle(SidebarListStyle())
            
            // Initial view
            Text("Selecione um item no menu")
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .frame(minWidth: 1000, minHeight: 600)
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
    }
}
