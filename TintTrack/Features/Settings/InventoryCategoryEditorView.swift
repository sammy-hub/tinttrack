import SwiftUI
import SwiftData

struct InventoryCategoryEditorView: View {
    let category: InventoryCategory

    @State private var showingAddField = false

    var body: some View {
        let ordered = (category.fieldDefinitions ?? []).sorted { $0.order < $1.order }

        return Form {
            Section("Category") {
                TextField("Name", text: Binding(
                    get: { category.name },
                    set: { category.name = $0 }
                ))
            }

            Section("Fields") {
                if ordered.isEmpty {
                    Text("No fields configured")
                        .foregroundStyle(.secondary)
                } else {
                    ForEach(ordered) { field in
                        InventoryFieldDefinitionRow(field: field)
                    }
                    .onDelete(perform: deleteFields)
                    .onMove(perform: moveFields)
                }
                Button("Add Field") {
                    showingAddField = true
                }
            }
        }
        .navigationTitle(category.name)
        .toolbar {
            EditButton()
        }
        .sheet(isPresented: $showingAddField) {
            AddInventoryFieldDefinitionView(category: category)
        }
    }

    private func deleteFields(at offsets: IndexSet) {
        var updated = (category.fieldDefinitions ?? []).sorted { $0.order < $1.order }
        updated.remove(atOffsets: offsets)
        updateOrders(with: updated)
    }

    private func moveFields(from source: IndexSet, to destination: Int) {
        var updated = (category.fieldDefinitions ?? []).sorted { $0.order < $1.order }
        updated.move(fromOffsets: source, toOffset: destination)
        updateOrders(with: updated)
    }

    private func updateOrders(with fields: [InventoryFieldDefinition]) {
        for (index, field) in fields.enumerated() {
            field.order = index
        }
        category.fieldDefinitions = fields
    }
}

struct InventoryFieldDefinitionRow: View {
    let field: InventoryFieldDefinition

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(field.name)
            Text(field.type.rawValue.capitalized)
                .foregroundStyle(.secondary)
        }
    }
}
