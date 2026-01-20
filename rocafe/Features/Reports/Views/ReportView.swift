import SwiftUI

struct ReportView: View {
    
    @StateObject private var viewModel = ReportViewModel()
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                
                // Header and Date Filter
                VStack(alignment: .leading) {
                    Text("Relatórios")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    
                    HStack {
                        DatePicker("Início", selection: Binding(
                            get: { viewModel.dateRange.lowerBound },
                            set: { viewModel.dateRange = $0...viewModel.dateRange.upperBound }
                        ), displayedComponents: .date)
                        
                        DatePicker("Fim", selection: Binding(
                            get: { viewModel.dateRange.upperBound },
                            set: { viewModel.dateRange = viewModel.dateRange.lowerBound...$0 }
                        ), displayedComponents: .date)
                    }
                    .padding(.top, 1)
                }
                .padding(.bottom)
                
                if viewModel.isLoading {
                    ProgressView("Gerando relatórios...")
                } else {
                    // DRE Simplificado
                    if let dre = viewModel.dreReport {
                        ReportCard(title: "DRE Simplificado") {
                            ReportRow(label: "Receita Total", value: dre.totalRevenue)
                            ReportRow(label: "Despesa Total", value: dre.totalExpenses, isNegative: true)
                            Divider()
                            ReportRow(label: "Resultado do Período", value: dre.netResult, isTotal: true)
                        }
                    }
                    
                    // Vendas por Forma de Pagamento
                    ReportCard(title: "Vendas por Forma de Pagamento") {
                        ForEach(viewModel.salesByPaymentMethod.sorted(by: { $0.key.rawValue < $1.key.rawValue }), id: \.key) { method, amount in
                            ReportRow(label: method.rawValue, value: amount)
                        }
                    }
                    
                    // TODO: Add other reports here
                    // - Despesas por Período
                    // - Vendas a Crédito
                }
                
                Spacer()
            }
            .padding()
        }
        .onAppear {
            viewModel.onAppear()
        }
    }
}

// MARK: - Sub-components for ReportView

struct ReportCard<Content: View>: View {
    let title: String
    @ViewBuilder let content: Content
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(title)
                .font(.title2)
                .fontWeight(.semibold)
            
            VStack {
                content
            }
            .padding()
            .background(Color(NSColor.windowBackgroundColor))
            .cornerRadius(8)
            .shadow(radius: 2)
        }
    }
}

struct ReportRow: View {
    let label: String
    let value: Decimal
    var isTotal: Bool = false
    var isNegative: Bool = false
    
    var body: some View {
        HStack {
            Text(label)
                .font(isTotal ? .headline : .body)
            Spacer()
            Text("\(isNegative ? "-" : "")\(value, format: .currency(code: "BRL"))")
                .font(isTotal ? .headline : .body)
                .foregroundColor(isTotal ? (value >= 0 ? .green : .red) : .primary)
        }
        .padding(.vertical, 2)
    }
}


struct ReportView_Previews: PreviewProvider {
    static var previews: some View {
        ReportView()
    }
}
