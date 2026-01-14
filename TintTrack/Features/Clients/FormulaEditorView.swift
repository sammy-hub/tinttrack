import Foundation
import SwiftUI
import SwiftData

struct FormulaEditorView: View {
    @Binding var formula: DraftFormula

    @State private var showingAddLineItem = false

    var body: some View {
        List {
            Section("Formula") {
                TextField("Name", text: $formula.name)
            }

            Section("Line Items") {
                if formula.lineItems.isEmpty {
                    Text("Add items and amounts used.")
                        .foregroundStyle(.secondary)
                } else {
                    ForEach($formula.lineItems) { $lineItem in
                        FormulaLineItemRow(lineItem: lineItem)
                    }
                    .onDelete(perform: deleteLineItem)
                }

                Button("Add Line Item") {
                    showingAddLineItem = true
                }
            }
        }
        .listStyle(.insetGrouped)
        .navigationTitle(formula.name.isEmpty ? "Formula" : formula.name)
        .sheet(isPresented: $showingAddLineItem) {
            AddFormulaLineItemView { newLineItem in
                formula.lineItems.append(newLineItem)
            }
        }
    }

    private func deleteLineItem(at offsets: IndexSet) {
        formula.lineItems.remove(atOffsets: offsets)
    }
}

struct FormulaLineItemRow: View {
    let lineItem: DraftLineItem
    @Query(sort: \AppSettings.id) private var settingsList: [AppSettings]

    var body: some View {
        let service = InventoryService()
        let cost = service.costForUsage(item: lineItem.inventoryItem, amountGrams: lineItem.amountGrams)
        let currencyCode = Locale.current.currency?.identifier ?? "USD"
        let unitsService = UnitsService()
        let preferredUnits = settingsList.first?.preferredUnits ?? .grams
        let displayAmount = unitsService.displayValue(fromGrams: lineItem.amountGrams, unit: preferredUnits)

        return HStack {
            Text(InventoryItemDisplay.title(for: lineItem.inventoryItem))
            Spacer()
            VStack(alignment: .trailing, spacing: 4) {
                HStack(spacing: 4) {
                    Text(displayAmount, format: .number.precision(.fractionLength(preferredUnits == .grams ? 0 : 2)))
                    Text(preferredUnits == .grams ? "g" : "oz")
                        .foregroundStyle(.secondary)
                }
                if let cost {
                    Text(cost, format: .currency(code: currencyCode))
                        .foregroundStyle(.secondary)
                }
            }
        }
        .accessibilityElement(children: .combine)
    }
}
