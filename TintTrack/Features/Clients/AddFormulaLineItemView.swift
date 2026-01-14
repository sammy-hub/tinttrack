import SwiftUI
import SwiftData

struct AddFormulaLineItemView: View {
    @Environment(\.dismiss) private var dismiss
    @Query(filter: #Predicate { $0.isArchived == false }, sort: \InventoryItem.id) private var items: [InventoryItem]
    @Query(sort: \AppSettings.id) private var settingsList: [AppSettings]

    let onSave: (DraftLineItem) -> Void

    @State private var selectedItem: InventoryItem?
    @State private var amountValue: Double = 0

    var body: some View {
        let preferredUnits = settingsList.first?.preferredUnits ?? .grams
        let amountStep = preferredUnits == .grams
            ? (settingsList.first?.stepSizeGrams ?? 5)
            : (settingsList.first?.stepSizeOunces ?? 0.1)

        return NavigationStack {
            List {
                Section("Inventory Item") {
                    if items.isEmpty {
                        Text("No inventory items available.")
                            .foregroundStyle(.secondary)
                    } else {
                        ForEach(items) { item in
                            Button {
                                selectedItem = item
                            } label: {
                                HStack {
                                    Text(InventoryItemDisplay.title(for: item))
                                    Spacer()
                                    if selectedItem?.id == item.id {
                                        Image(systemName: "checkmark")
                                            .foregroundStyle(.tint)
                                    }
                                }
                            }
                            .accessibilityLabel(InventoryItemDisplay.title(for: item))
                        }
                    }
                }

                Section("Amount Used") {
                    Stepper(value: $amountValue, in: 0...10000, step: amountStep) {
                        HStack {
                            Text("Amount")
                            Spacer()
                            Text(amountValue, format: .number.precision(.fractionLength(preferredUnits == .grams ? 0 : 2)))
                            Text(preferredUnits == .grams ? "g" : "oz")
                                .foregroundStyle(.secondary)
                        }
                    }
                }
            }
            .listStyle(.insetGrouped)
            .navigationTitle("Add Line Item")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        save()
                    }
                    .disabled(selectedItem == nil || amountValue <= 0)
                }
            }
            .onChange(of: preferredUnits) { oldValue, newValue in
                let service = UnitsService()
                let grams = service.grams(from: amountValue, unit: oldValue)
                amountValue = service.displayValue(fromGrams: grams, unit: newValue)
            }
        }
    }

    private func save() {
        guard let selectedItem else {
            return
        }
        let service = UnitsService()
        let preferredUnits = settingsList.first?.preferredUnits ?? .grams
        let amountGrams = service.grams(from: amountValue, unit: preferredUnits)
        let lineItem = DraftLineItem(inventoryItem: selectedItem, amountGrams: amountGrams)
        onSave(lineItem)
        dismiss()
    }
}
