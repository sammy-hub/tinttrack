import SwiftUI
import SwiftData

struct AdjustStockView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    let item: InventoryItem

    @State private var amountUnits: Double = 0
    @State private var adjustmentType: AdjustmentType = .add
    @State private var showingNegativeAlert = false

    enum AdjustmentType: String, CaseIterable, Identifiable {
        case add
        case subtract

        var id: String { rawValue }
        var label: String {
            switch self {
            case .add:
                return "Add"
            case .subtract:
                return "Subtract"
            }
        }
    }

    var body: some View {
        let unitSizeGrams = item.unitSizeGrams
        let canAdjust = unitSizeGrams > 0

        return NavigationStack {
            Form {
                Section("Adjustment") {
                    Picker("Type", selection: $adjustmentType) {
                        ForEach(AdjustmentType.allCases) { type in
                            Text(type.label).tag(type)
                        }
                    }
                    .pickerStyle(.segmented)

                    Stepper(value: $amountUnits, in: 0...10000, step: 1) {
                        HStack {
                            Text("Units")
                            Spacer()
                            Text(amountUnits, format: .number.precision(.fractionLength(0)))
                            Text("units")
                                .foregroundStyle(.secondary)
                        }
                    }
                }

                if canAdjust == false {
                    Section {
                        Text("Set the unit size to adjust stock.")
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .navigationTitle("Adjust Stock")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        handleSave()
                    }
                    .disabled(amountUnits <= 0 || canAdjust == false)
                }
            }
            .alert("Allow Negative Stock?", isPresented: $showingNegativeAlert) {
                Button("Allow Negative") {
                    applyAdjustment(allowNegative: true)
                }
                Button("Cancel", role: .cancel) { }
            } message: {
                Text("This adjustment would bring stock below zero.")
            }
        }
    }

    private func handleSave() {
        let deltaGrams = adjustmentDeltaGrams()
        if item.currentStockGrams + deltaGrams < 0 {
            showingNegativeAlert = true
        } else {
            applyAdjustment(allowNegative: false)
        }
    }

    private func applyAdjustment(allowNegative: Bool) {
        let deltaGrams = adjustmentDeltaGrams()
        if allowNegative == false, item.currentStockGrams + deltaGrams < 0 {
            return
        }
        item.currentStockGrams += deltaGrams
        let transaction = InventoryTransaction(
            inventoryItem: item,
            date: Date(),
            deltaGrams: deltaGrams,
            reason: .manualAdjustment,
            relatedVisit: nil
        )
        modelContext.insert(transaction)
        dismiss()
    }

    private func adjustmentDeltaGrams() -> Double {
        let unitSizeGrams = item.unitSizeGrams
        let deltaUnits = adjustmentType == .add ? amountUnits : -amountUnits
        return deltaUnits * unitSizeGrams
    }
}
