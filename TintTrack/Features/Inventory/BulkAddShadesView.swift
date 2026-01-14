import SwiftUI
import SwiftData

struct BulkAddShadesView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Query(sort: \AppSettings.id) private var settingsList: [AppSettings]

    let category: InventoryCategory

    @State private var brand = ""
    @State private var productLine = ""
    @State private var cost = ""
    @State private var unitSizeValue: Double = 0
    @State private var defaultStockUnits: Double = 0
    @State private var shadesText = ""

    var body: some View {
        let preferredUnits = settingsList.first?.preferredUnits ?? .grams
        let unitSizeStep = preferredUnits == .grams
            ? (settingsList.first?.stepSizeGrams ?? 5)
            : (settingsList.first?.stepSizeOunces ?? 0.1)

        return NavigationStack {
            Form {
                Section("Shared Info") {
                    TextField("Brand", text: $brand)
                    TextField("Product Line", text: $productLine)
                    TextField("Cost", text: $cost)
                        .keyboardType(.decimalPad)
                }

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

                Section("Default Stock") {
                    Stepper(value: $defaultStockUnits, in: 0...10000, step: 1) {
                        HStack {
                            Text("Units Per Shade")
                            Spacer()
                            Text(defaultStockUnits, format: .number.precision(.fractionLength(0)))
                            Text("units")
                                .foregroundStyle(.secondary)
                        }
                    }
                }

                Section("Shades") {
                    TextField("One shade per line. Optional: shade, units", text: $shadesText, axis: .vertical)
                        .lineLimit(4...10)
                    Text("Example: 9V, 6\n7N, 3")
                        .foregroundStyle(.secondary)
                }
            }
            .navigationTitle("Add Shades")
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
                    .disabled(unitSizeValue <= 0 || shadesText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
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
        let trimmedLines = shadesText
            .split(whereSeparator: \.isNewline)
            .map { String($0).trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { $0.isEmpty == false }

        guard trimmedLines.isEmpty == false, unitSizeValue > 0 else {
            return
        }

        let service = UnitsService()
        let preferredUnits = settingsList.first?.preferredUnits ?? .grams
        let unitSizeGrams = service.grams(from: unitSizeValue, unit: preferredUnits)
        let hasProductSizeField = (category.fieldDefinitions ?? []).contains {
            $0.name == InventoryFieldKeys.productSize
        }
        let productSizeValue = formattedUnitSize(unitSizeValue, unit: preferredUnits)
        let trimmedBrand = brand.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedProductLine = productLine.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedCost = cost.trimmingCharacters(in: .whitespacesAndNewlines)

        for line in trimmedLines {
            guard let parsed = parseShadeLine(line) else {
                continue
            }

            let units = parsed.units ?? defaultStockUnits
            let currentStockGrams = unitSizeGrams * units

            var fields: [String: String] = [
                InventoryFieldKeys.title: parsed.shade,
                InventoryFieldKeys.shade: parsed.shade
            ]
            if trimmedBrand.isEmpty == false {
                fields[InventoryFieldKeys.brand] = trimmedBrand
            }
            if trimmedProductLine.isEmpty == false {
                fields[InventoryFieldKeys.productLine] = trimmedProductLine
            }
            if trimmedCost.isEmpty == false {
                fields[InventoryFieldKeys.cost] = trimmedCost
            }
            if hasProductSizeField {
                fields[InventoryFieldKeys.productSize] = productSizeValue
            }

            let item = InventoryItem(
                category: category,
                fieldValues: fields,
                currentStockGrams: currentStockGrams,
                lowStockThresholdGrams: 0,
                unitSizeGrams: unitSizeGrams,
                isArchived: false
            )
            modelContext.insert(item)
        }

        dismiss()
    }

    private func parseShadeLine(_ line: String) -> (shade: String, units: Double?)? {
        let trimmed = line.trimmingCharacters(in: .whitespacesAndNewlines)
        guard trimmed.isEmpty == false else {
            return nil
        }

        if let separator = lineSeparator(in: trimmed) {
            let parts = trimmed.split(separator: separator, maxSplits: 1)
            let shade = parts.first?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
            guard shade.isEmpty == false else {
                return nil
            }
            let unitsText = parts.count > 1
                ? parts[1].trimmingCharacters(in: .whitespacesAndNewlines)
                : ""
            let unitsValue = Double(unitsText)
            return (shade: shade, units: unitsValue)
        }

        return (shade: trimmed, units: nil)
    }

    private func lineSeparator(in line: String) -> Character? {
        if line.contains(",") {
            return ","
        }
        if line.contains("\t") {
            return "\t"
        }
        return nil
    }

    private func formattedUnitSize(_ value: Double, unit: Units) -> String {
        let formatter = NumberFormatter()
        formatter.minimumFractionDigits = 0
        formatter.maximumFractionDigits = unit == .grams ? 0 : 2
        return formatter.string(from: NSNumber(value: value)) ?? "\(value)"
    }
}
