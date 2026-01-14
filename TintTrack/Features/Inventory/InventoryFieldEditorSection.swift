import SwiftUI

struct InventoryFieldEditorSection: View {
    let title: String
    let fieldDefinitions: [InventoryFieldDefinition]
    @Binding var fieldValues: [String: String]

    var body: some View {
        let ordered = fieldDefinitions.sorted { $0.order < $1.order }

        return Section(title) {
            if ordered.isEmpty {
                Text("No fields configured")
                    .foregroundStyle(.secondary)
            } else {
                ForEach(ordered) { field in
                    InventoryFieldRow(field: field, fieldValues: $fieldValues)
                }
            }
        }
    }
}

struct InventoryFieldRow: View {
    let field: InventoryFieldDefinition
    @Binding var fieldValues: [String: String]

    var body: some View {
        let key = field.name
        let textBinding = Binding(
            get: { fieldValues[key] ?? "" },
            set: { newValue in
                if newValue.isEmpty {
                    fieldValues.removeValue(forKey: key)
                } else {
                    fieldValues[key] = newValue
                }
            }
        )
        let toggleBinding = Binding(
            get: { (fieldValues[key] ?? "false").lowercased() == "true" },
            set: { newValue in
                fieldValues[key] = newValue ? "true" : "false"
            }
        )
        let options = field.pickerOptions ?? []

        return Group {
            switch field.type {
            case .text:
                TextField(field.name, text: textBinding)
            case .number:
                TextField(field.name, text: textBinding)
                    .keyboardType(.decimalPad)
            case .toggle:
                Toggle(field.name, isOn: toggleBinding)
            case .picker:
                Picker(field.name, selection: textBinding) {
                    Text("Select").tag("")
                    ForEach(options, id: \.self) { option in
                        Text(option).tag(option)
                    }
                }
            case .barcode:
                TextField(field.name, text: textBinding)
                    .textContentType(.none)
            }
        }
    }
}
