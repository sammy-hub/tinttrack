import SwiftUI
import SwiftData

struct InventoryRootView: View {
    @Query(sort: \InventoryCategory.name, order: .forward) private var categories: [InventoryCategory]
    @Query private var items: [InventoryItem]

    @State private var showingAddCategory = false

    var body: some View {
        let itemCounts = items.reduce(into: [UUID: Int]()) { partialResult, item in
            guard let categoryID = item.category?.id else {
                return
            }
            partialResult[categoryID, default: 0] += 1
        }

        return NavigationStack {
            List {
                if categories.isEmpty {
                    Section {
                        InventoryEmptyStateView(action: {
                            showingAddCategory = true
                        })
                    }
                } else {
                    Section {
                        ForEach(categories) { category in
                            NavigationLink(value: category.id) {
                                InventoryCategoryRow(
                                    category: category,
                                    itemCount: itemCounts[category.id] ?? 0
                                )
                            }
                        }
                    }
                }
            }
            .listStyle(.insetGrouped)
            .navigationTitle("Inventory")
            .navigationDestination(for: UUID.self) { categoryID in
                InventoryCategoryDetailView(categoryID: categoryID)
            }
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
}

struct InventoryEmptyStateView: View {
    let action: () -> Void

    var body: some View {
        ContentUnavailableView {
            Label("No Categories", systemImage: "shippingbox")
        } description: {
            Text("Add a category to organize inventory items.")
        } actions: {
            Button("Add Category") {
                action()
            }
        }
    }
}

struct InventoryCategoryRow: View {
    let category: InventoryCategory
    let itemCount: Int

    var body: some View {
        HStack {
            Text(category.name)
            Spacer()
            Text("\(itemCount)")
                .foregroundStyle(.secondary)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(category.name), \(itemCount) items")
    }
}
