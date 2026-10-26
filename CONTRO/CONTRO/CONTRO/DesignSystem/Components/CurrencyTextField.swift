//
//  CurrencyTextField.swift
//  SplitEase
//
//  Created for SplitEase.
//

import SwiftUI

public struct CurrencyTextField: View {
    @Binding var minorUnits: Int64
    var currency: Currency = .inr
    var placeholder: String = "0.00"

    @State private var text: String = ""

    public init(minorUnits: Binding<Int64>, currency: Currency = .inr, placeholder: String = "0.00") {
        self._minorUnits = minorUnits
        self.currency = currency
        self.placeholder = placeholder
    }

    public var body: some View {
        HStack(alignment: .firstTextBaseline, spacing: 6) {
            Text(currency.symbol)
                .font(.system(size: 32, weight: .bold, design: .rounded))
                .foregroundColor(.secondary)

            TextField(placeholder, text: $text)
                .font(.system(size: 38, weight: .bold, design: .rounded))
                .keyboardType(.decimalPad)
                .onAppear {
                    if minorUnits > 0 {
                        text = String(format: "%.2f", MinorUnits.toMajorDouble(minorUnits, currency: currency))
                    }
                }
                .onChange(of: text) { _, newValue in
                    if let parsed = MinorUnits.parse(newValue, currency: currency) {
                        minorUnits = parsed
                    } else if newValue.isEmpty {
                        minorUnits = 0
                    }
                }
                .onChange(of: minorUnits) { _, newValue in
                    let formatted = String(format: "%.2f", MinorUnits.toMajorDouble(newValue, currency: currency))
                    if MinorUnits.parse(text, currency: currency) != newValue {
                        text = newValue > 0 ? formatted : ""
                    }
                }
        }
        .padding(.vertical, 8)
    }
}
