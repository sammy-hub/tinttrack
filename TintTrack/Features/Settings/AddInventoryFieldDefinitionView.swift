import SwiftUI
import SwiftData

struct AddInventoryFieldDefinitionView: View {
    @Environment(\.dismiss) private var dismiss

    let category: InventoryCategory

    @State private var name = ""
    @State private var type: InventoryFieldType = .text
    @State private var pickerOptionsText = ""

    var body: some View {
        NavigationStack {
            Form {
                Section("Field") {
                    TextField("Name", text: $name)
                    Picker("Type", selection: $type) {
                        ForEach(InventoryFieldType.allCases, id: \.self) { fieldType in
                            Text(fieldType.rawValue.capitalized)
                                .tag(fieldType)
                        }
                    }
                }

                if type == .picker {
                    Section("Picker Options") {
                        TextField("Comma-separated options", text: $pickerOptionsText)
                    }
                }
            }
            .navigationTitle("New Field")
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
                    .disabled(name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
        }
    }

    private func save() {
        let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard trimmed.isEmpty == false else {
            return
        }

        let nextOrder = (category.fieldDefinitions ?? []).count
        let options = pickerOptionsText
            .split(separator: ",")
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { $0.isEmpty == false }

        let field = InventoryFieldDefinition(
            name: trimmed,
            type: type,
            pickerOptions: options.isEmpty ? nil : options,
            order: nextOrder
        )

        var updated = category.fieldDefinitions ?? []
        updated.append(field)
        category.fieldDefinitions = updated
        dismiss()
    }
}
