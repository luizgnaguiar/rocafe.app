import SwiftUI
import Combine

struct DecimalTextField: View {
    let title: String
    @Binding var value: Decimal?
    
    @State private var stringValue: String = ""
    
    private static var formatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.minimumFractionDigits = 2
        formatter.maximumFractionDigits = 2
        // Use locale that uses comma as decimal separator, like pt_BR
        formatter.locale = Locale(identifier: "pt_BR")
        return formatter
    }()
    
    var body: some View {
        TextField(title, text: $stringValue)
            .onAppear(perform: {
                // Set initial string value
                if let val = value {
                    stringValue = Self.formatter.string(from: val as NSDecimalNumber) ?? ""
                } else {
                    stringValue = ""
                }
            })
            .onChange(of: stringValue) { newValue in
                // When the string changes, try to convert it to a Decimal
                if let number = Self.formatter.number(from: newValue) {
                    value = number.decimalValue
                } else {
                    // If conversion fails, it might be an empty string or invalid input
                    if newValue.isEmpty {
                        value = nil
                    }
                }
            }
            .onChange(of: value) { newValue in
                // When the binding value changes from outside, update the string
                if let val = newValue, stringValue != Self.formatter.string(from: val as NSDecimalNumber) {
                     stringValue = Self.formatter.string(from: val as NSDecimalNumber) ?? ""
                } else if newValue == nil {
                    stringValue = ""
                }
            }
    }
}
