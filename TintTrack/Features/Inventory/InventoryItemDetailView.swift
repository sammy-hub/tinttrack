import SwiftUI
import SwiftData

struct InventoryItemDetailView: View {
    @Query private var items: [InventoryItem]
    @Query private var transactions: [InventoryTransaction]
    @Query private var settingsList: [AppSettings]

    let itemID: UUID

    @State private var showingAdjustStock = false

    init(itemID: UUID) {
        self.itemID = itemID
        _items = Query(filter: #Predicate { $0.id == itemID })
        _transactions = Query(
            filter: #Predicate { $0.inventoryItem?.id == itemID },
            sort: \InventoryTransaction.date,
            order: .reverse
        )
        _settingsList = Query(sort: \AppSettings.id)
    }

    var body: some View {
        let preferredUnits = settingsList.first?.preferredUnits ?? .grams
        let stepSize = preferredUnits == .grams
            ? (settingsList.first?.stepSizeGrams ?? 5)
            : (settingsList.first?.stepSizeOunces ?? 0.1)

        if let item = items.first {
            InventoryItemDetailContent(
                item: item,
                transactions: transactions,
                showingAdjustStock: $showingAdjustStock,
                preferredUnits: preferredUnits,
                stepSize: stepSize
            )
            .sheet(isPresented: $showingAdjustStock) {
                AdjustStockView(item: item)
            }
        } else {
            ContentUnavailableView {
                Label("Item Missing", systemImage: "exclamationmark.triangle")
            } description: {
                Text("This item is no longer available.")
            }
        }
    }
}

struct InventoryItemDetailContent: View {
    let item: InventoryItem
    let transactions: [InventoryTransaction]
    @Binding var showingAdjustStock: Bool
    let preferredUnits: Units
    let stepSize: Double

    @State private var unitSizeValue: Double

    init(
        item: InventoryItem,
        transactions: [InventoryTransaction],
        showingAdjustStock: Binding<Bool>,
        preferredUnits: Units,
        stepSize: Double
    ) {
        self.item = item
        self.transactions = transactions
        self._showingAdjustStock = showingAdjustStock
        self.preferredUnits = preferredUnits
        self.stepSize = stepSize

        let service = UnitsService()
        let startingValue = service.displayValue(fromGrams: item.unitSizeGrams, unit: preferredUnits)
        self._unitSizeValue = State(initialValue: startingValue)
    }

    var body: some View {
        let service = UnitsService()
        let unitSizeGrams = item.unitSizeGrams
        let unitsRemaining = unitSizeGrams > 0 ? item.currentStockGrams / unitSizeGrams : nil
        let thresholdUnits = unitSizeGrams > 0 ? item.lowStockThresholdGrams / unitSizeGrams : 0

        let fieldValuesBinding = Binding(
            get: { item.fieldValues },
            set: { item.fieldValues = $0 }
        )
        let lowStockBinding = Binding(
            get: { thresholdUnits },
            set: { newValue in
                if unitSizeGrams > 0 {
                    item.lowStockThresholdGrams = newValue * unitSizeGrams
                } else {
                    item.lowStockThresholdGrams = 0
                }
            }
        )
        let archivedBinding = Binding(
            get: { item.isArchived },
            set: { item.isArchived = $0 }
        )

        return Form {
            InventoryFieldEditorSection(
                title: "Details",
                fieldDefinitions: item.category?.fieldDefinitions ?? [],
                fieldValues: fieldValuesBinding
            )

            Section("Unit Size") {
                Stepper(value: $unitSizeValue, in: 0...1000, step: stepSize) {
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
                HStack {
                    Text("Current Stock")
                    Spacer()
                    if let unitsRemaining {
                        Text(unitsRemaining, format: .number.precision(.fractionLength(2)))
                        Text("units")
                            .foregroundStyle(.secondary)
                    } else {
                        Text("Set unit size")
                            .foregroundStyle(.secondary)
                    }
                }
                Stepper(value: lowStockBinding, in: 0...10000, step: 1) {
                    HStack {
                        Text("Low Stock Threshold")
                        Spacer()
                        Text(thresholdUnits, format: .number.precision(.fractionLength(0)))
                        Text("units")
                            .foregroundStyle(.secondary)
                    }
                }
                .disabled(unitSizeGrams <= 0)

                Toggle("Archived", isOn: archivedBinding)
            }

            Section {
                Button("Adjust Stock") {
                    showingAdjustStock = true
                }
                .disabled(unitSizeGrams <= 0)
            }

            Section("Usage History") {
                if transactions.isEmpty {
                    Text("No usage yet")
                        .foregroundStyle(.secondary)
                } else {
                    ForEach(transactions) { transaction in
                        InventoryTransactionRow(
                            transaction: transaction,
                            preferredUnits: preferredUnits
                        )
                    }
                }
            }
        }
        .navigationTitle(InventoryItemDisplay.title(for: item))
        .onChange(of: preferredUnits) { oldValue, newValue in
            let grams = service.grams(from: unitSizeValue, unit: oldValue)
            unitSizeValue = service.displayValue(fromGrams: grams, unit: newValue)
        }
        .onChange(of: unitSizeValue) { _, newValue in
            item.unitSizeGrams = service.grams(from: newValue, unit: preferredUnits)
        }
    }
}

struct InventoryTransactionRow: View {
    let transaction: InventoryTransaction
    let preferredUnits: Units

    var body: some View {
        let service = UnitsService()
        let displayValue = service.displayValue(fromGrams: transaction.deltaGrams, unit: preferredUnits)

        HStack {
            Text(transaction.date, format: .dateTime.year().month().day())
            Spacer()
            Text(displayValue, format: .number.precision(.fractionLength(preferredUnits == .grams ? 0 : 2)))
            Text(preferredUnits == .grams ? "g" : "oz")
                .foregroundStyle(.secondary)
        }
        .accessibilityElement(children: .combine)
    }
}
