import SwiftUI
import SwiftData

struct QuickAddInventoryItemView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Query(sort: \AppSettings.id) private var settingsList: [AppSettings]

    let category: InventoryCategory

    @State private var fieldValues: [String: String] = [:]
    @State private var unitSizeValue: Double = 0
    @State private var initialStockUnits: Double = 0

    var body: some View {
        let titleValue = fieldValues[InventoryFieldKeys.title] ?? ""
        let preferredUnits = settingsList.first?.preferredUnits ?? .grams
        let unitSizeStep = preferredUnits == .grams
            ? (settingsList.first?.stepSizeGrams ?? 5)
            : (settingsList.first?.stepSizeOunces ?? 0.1)

        return NavigationStack {
            Form {
                InventoryFieldEditorSection(
                    title: "Item",
                    fieldDefinitions: category.fieldDefinitions ?? [],
                    fieldValues: $fieldValues
                )

                Section("Unit Size") {
                    Stepper(value: $unitSizeValue, in: 0...1000, step: unitSizeStep) {
                        HStack {
                            Text("Unit Size")
                            Spacer()
                            Text(unitSizeValue, format: .number.precision(.fractionLength(preferredUnits == .grams ? 0 : 2)))
                            Text(preferredUnits == .grams ? "g" : "oz")
                                .foregroundStyle(.secondary)
                        }
                    }
                    Text("Enter grams or ounces per tube or bottle.")
                        .foregroundStyle(.secondary)
                }

                Section("Stock") {
                    Stepper(value: $initialStockUnits, in: 0...10000, step: 1) {
                        HStack {
                            Text("Initial Stock")
                            Spacer()
                            Text(initialStockUnits, format: .number.precision(.fractionLength(0)))
                            Text("units")
                                .foregroundStyle(.secondary)
                        }
                    }
                }
            }
            .navigationTitle("New Item")
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
                    .disabled(titleValue.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || unitSizeValue <= 0)
                }
            }
            .onChange(of: preferredUnits) { oldValue, newValue in
                let service = UnitsService()
                let grams = service.grams(from: unitSizeValue, unit: oldValue)
                unitSizeValue = service.displayValue(fromGrams: grams, unit: newValue)
            }
        }
    }

    private func save() {
        let trimmedTitle = (fieldValues[InventoryFieldKeys.title] ?? "")
            .trimmingCharacters(in: .whitespacesAndNewlines)
        guard trimmedTitle.isEmpty == false, unitSizeValue > 0 else {
            return
        }

        let service = UnitsService()
        let preferredUnits = settingsList.first?.preferredUnits ?? .grams
        let unitSizeGrams = service.grams(from: unitSizeValue, unit: preferredUnits)

        fieldValues[InventoryFieldKeys.title] = trimmedTitle
        if shouldStoreProductSize() {
            fieldValues[InventoryFieldKeys.productSize] = formattedUnitSize(unitSizeValue, unit: preferredUnits)
        }
        let cleaned = fieldValues.filter { $0.value.isEmpty == false }
        let currentStockGrams = unitSizeGrams * initialStockUnits

        let item = InventoryItem(
            category: category,
            fieldValues: cleaned,
            currentStockGrams: currentStockGrams,
            lowStockThresholdGrams: 0,
            unitSizeGrams: unitSizeGrams,
            isArchived: false
        )
        modelContext.insert(item)
        dismiss()
    }

    private func shouldStoreProductSize() -> Bool {
        guard let definitions = category.fieldDefinitions else {
            return false
        }
        let hasProductSizeField = definitions.contains { $0.name == InventoryFieldKeys.productSize }
        let existingValue = fieldValues[InventoryFieldKeys.productSize] ?? ""
        return hasProductSizeField && existingValue.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    private func formattedUnitSize(_ value: Double, unit: Units) -> String {
        let formatter = NumberFormatter()
        formatter.minimumFractionDigits = 0
        formatter.maximumFractionDigits = unit == .grams ? 0 : 2
        return formatter.string(from: NSNumber(value: value)) ?? "\(value)"
    }
}
