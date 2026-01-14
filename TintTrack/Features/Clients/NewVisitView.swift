import SwiftUI
import SwiftData

struct NewVisitView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Query(sort: \AppSettings.id) private var settingsList: [AppSettings]

    let client: Client

    @State private var visitDate = Date()
    @State private var notes = ""
    @State private var formulas: [DraftFormula] = []

    @State private var showingInsufficientAlert = false
    @State private var insufficientMessage = ""

    var body: some View {
        let isValid = validate()

        return NavigationStack {
            List {
                Section("Visit") {
                    DatePicker("Date", selection: $visitDate, displayedComponents: .date)
                    TextField("Notes", text: $notes, axis: .vertical)
                        .lineLimit(2...6)
                }

                Section("Formulas") {
                    if formulas.isEmpty {
                        Text("Add a formula to track inventory usage.")
                            .foregroundStyle(.secondary)
                    } else {
                        ForEach($formulas) { $formula in
                            NavigationLink {
                                FormulaEditorView(formula: $formula)
                            } label: {
                                FormulaRow(formula: formula)
                            }
                        }
                        .onDelete(perform: deleteFormula)
                    }

                    Button("Add Formula") {
                        formulas.append(DraftFormula())
                    }
                }
            }
            .listStyle(.insetGrouped)
            .navigationTitle("New Visit")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        saveVisit(allowNegative: false)
                    }
                    .disabled(isValid == false)
                }
            }
            .alert("Insufficient Stock", isPresented: $showingInsufficientAlert) {
                Button("Allow Negative") {
                    saveVisit(allowNegative: true)
                }
                Button("Edit Amount") { }
                Button("Cancel Save", role: .cancel) { }
            } message: {
                Text(insufficientMessage)
            }
        }
    }

    private func validate() -> Bool {
        guard formulas.isEmpty == false else {
            return false
        }
        for formula in formulas {
            let trimmed = formula.name.trimmingCharacters(in: .whitespacesAndNewlines)
            if trimmed.isEmpty {
                return false
            }
            if formula.lineItems.isEmpty {
                return false
            }
        }
        return true
    }

    private func deleteFormula(at offsets: IndexSet) {
        formulas.remove(atOffsets: offsets)
    }

    private func saveVisit(allowNegative: Bool) {
        let visit = Visit(date: visitDate, client: client, formulas: [], notes: notes)

        var allLineItems: [FormulaLineItem] = []
        var formulaModels: [Formula] = []

        for draft in formulas {
            let formula = Formula(name: draft.name, visit: visit, lineItems: [])
            var lineItemModels: [FormulaLineItem] = []

            for lineItem in draft.lineItems {
                let model = FormulaLineItem(
                    inventoryItem: lineItem.inventoryItem,
                    amountUsedGrams: lineItem.amountGrams
                )
                lineItemModels.append(model)
                allLineItems.append(model)
            }

            formula.lineItems = lineItemModels
            formulaModels.append(formula)
        }

        let service = FormulaService()
        do {
            let transactions = try service.deductInventory(
                for: allLineItems,
                visit: visit,
                allowNegative: allowNegative
            )

            visit.formulas = formulaModels
            var updatedVisits = client.visits ?? []
            updatedVisits.append(visit)
            client.visits = updatedVisits

            modelContext.insert(visit)
            for formula in formulaModels {
                modelContext.insert(formula)
            }
            for lineItem in allLineItems {
                modelContext.insert(lineItem)
            }
            for transaction in transactions {
                modelContext.insert(transaction)
            }

            dismiss()
        } catch let error as FormulaService.FormulaServiceError {
            switch error {
            case .insufficientStock(let insufficient):
                let preferredUnits = settingsList.first?.preferredUnits ?? .grams
                let unitsService = UnitsService()
                insufficientMessage = insufficient
                    .map { item in
                        let title = InventoryItemDisplay.title(for: item.item)
                        let required = unitsService.displayValue(fromGrams: item.requiredGrams, unit: preferredUnits)
                        let available = unitsService.displayValue(fromGrams: item.availableGrams, unit: preferredUnits)
                        let unitLabel = preferredUnits == .grams ? "g" : "oz"
                        return "\(title): needs \(formattedAmount(required, unit: preferredUnits))\(unitLabel), has \(formattedAmount(available, unit: preferredUnits))\(unitLabel)"
                    }
                    .joined(separator: "\n")
                showingInsufficientAlert = true
            case .archivedItemUsed:
                insufficientMessage = "An archived item is in this formula. Please choose an active item."
                showingInsufficientAlert = true
            }
        } catch {
            insufficientMessage = "Unable to save visit. Please try again."
            showingInsufficientAlert = true
        }
    }

    private func formattedAmount(_ value: Double, unit: Units) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.minimumFractionDigits = 0
        formatter.maximumFractionDigits = unit == .grams ? 0 : 2
        return formatter.string(from: NSNumber(value: value)) ?? "\(value)"
    }
}

struct FormulaRow: View {
    let formula: DraftFormula

    var body: some View {
        HStack {
            Text(formula.name.isEmpty ? "Untitled Formula" : formula.name)
            Spacer()
            Text("\(formula.lineItems.count)")
                .foregroundStyle(.secondary)
        }
    }
}
