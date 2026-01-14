import SwiftUI
import SwiftData

struct InventoryCategoriesSettingsView: View {
    @Query(sort: \InventoryCategory.name, order: .forward) private var categories: [InventoryCategory]

    @State private var showingAddCategory = false

    var body: some View {
        List {
            if categories.isEmpty {
                Section {
                    ContentUnavailableView {
                        Label("No Categories", systemImage: "shippingbox")
                    } description: {
                        Text("Add categories to define item fields.")
                    } actions: {
                        Button("Add Category") {
                            showingAddCategory = true
                        }
                    }
                }
            } else {
                Section {
                    ForEach(categories) { category in
                        NavigationLink(category.name) {
                            InventoryCategoryEditorView(category: category)
                        }
                    }
                }
            }
        }
        .listStyle(.insetGrouped)
        .navigationTitle("Inventory Categories")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    showingAddCategory = true
                } label: {
                    Label("Add Category", systemImage: "plus")
                }
            }
        }
        .sheet(isPresented: $showingAddCategory) {
            AddInventoryCategoryView()
        }
    }
}
