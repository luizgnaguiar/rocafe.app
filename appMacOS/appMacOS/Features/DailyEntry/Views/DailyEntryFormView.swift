import SwiftUI

struct DailyEntryFormView: View {
    
    @StateObject private var viewModel: DailyEntryViewModel
    
    init(entry: DailyEntry? = nil) {
        _viewModel = StateObject(wrappedValue: DailyEntryViewModel(entry: entry))
    }
    
    // TODO: Create a proper decimal number formatter
    private var numberFormatter: NumberFormatter = {
        let f = NumberFormatter()
        f.numberStyle = .decimal
        f.minimumFractionDigits = 2
        f.maximumFractionDigits = 2
        return f
    }()
    
    var body: some View {
        Form {
            Section(header: Text("Data do Lançamento")) {
                DatePicker("Data", selection: $viewModel.dailyEntry.date, displayedComponents: .date)
            }
            
            Section(header: Text("Vendas do Dia")) {
                // TODO: Replace with a custom DecimalTextField component
                HStack {
                    Text("Dinheiro")
                    Spacer()
                    TextField("Valor", value: $viewModel.dailyEntry.salesCash, formatter: numberFormatter)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .frame(width: 120)
                }
                HStack {
                    Text("Crédito")
                    Spacer()
                    TextField("Valor", value: $viewModel.dailyEntry.salesCredit, formatter: numberFormatter)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .frame(width: 120)
                }
                HStack {
                    Text("Débito")
                    Spacer()
                    TextField("Valor", value: $viewModel.dailyEntry.salesDebit, formatter: numberFormatter)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .frame(width: 120)
                }
                HStack {
                    Text("PIX")
                    Spacer()
                    TextField("Valor", value: $viewModel.dailyEntry.salesPix, formatter: numberFormatter)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .frame(width: 120)
                }
            }
            
            Section(header: Text("Contas Recebidas")) {
                HStack {
                    Text("Dinheiro")
                    Spacer()
                    TextField("Valor", value: $viewModel.dailyEntry.receivedCash, formatter: numberFormatter)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .frame(width: 120)
                }
                HStack {
                    Text("Crédito")
                    Spacer()
                    TextField("Valor", value: $viewModel.dailyEntry.receivedCredit, formatter: numberFormatter)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .frame(width: 120)
                }
                HStack {
                    Text("Débito")
                    Spacer()
                    TextField("Valor", value: $viewModel.dailyEntry.receivedDebit, formatter: numberFormatter)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .frame(width: 120)
                }
                HStack {
                    Text("PIX")
                    Spacer()
                    TextField("Valor", value: $viewModel.dailyEntry.receivedPix, formatter: numberFormatter)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .frame(width: 120)
                }
            }
            
            if let errorMessage = viewModel.errorMessage {
                Section {
                    Text(errorMessage)
                        .foregroundColor(.red)
                }
            }
            
            Section {
                Button(action: {
                    viewModel.save()
                }) {
                    HStack {
                        Spacer()
                        if viewModel.isLoading {
                            ProgressView()
                        } else {
                            Text("Salvar Lançamento")
                        }
                        Spacer()
                    }
                }
                .disabled(viewModel.isLoading)
            }
        }
        .navigationTitle("Lançamento Diário")
        .padding()
    }
}

struct DailyEntryFormView_Previews: PreviewProvider {
    static var previews: some View {
        DailyEntryFormView()
    }
}
