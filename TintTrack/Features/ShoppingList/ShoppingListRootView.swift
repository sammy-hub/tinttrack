import SwiftUI
import SwiftData

struct ShoppingListRootView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(filter: #Predicate { $0.isArchived == false }, sort: \InventoryItem.id)
    private var inventoryItems: [InventoryItem]
    @Query(sort: \ShoppingListItem.createdAt) private var shoppingItems: [ShoppingListItem]

    @State private var showingAddManualItem = false
    @State private var showingClearPurchasedConfirm = false

    var body: some View {
        let service = InventoryService()
        let lowStockItems = service.lowStockItems(from: inventoryItems)
        let manualItems = shoppingItems.filter { $0.isManual }
        let hasItems = lowStockItems.isEmpty == false || manualItems.isEmpty == false

        return NavigationStack {
            List {
                if hasItems == false {
                    Section {
                        ShoppingListEmptyStateView {
                            showingAddManualItem = true
                        }
                    }
                } else {
                    if lowStockItems.isEmpty == false {
                        Section("Needs Restock") {
                            ForEach(lowStockItems) { item in
                                ShoppingListInventoryRow(
                                    item: item,
                                    entry: entry(for: item)
                                ) { isPurchased in
                                    togglePurchased(for: item, isPurchased: isPurchased)
                                }
                            }
                        }
                    }

                    if manualItems.isEmpty == false {
                        Section("Manual") {
                            ForEach(manualItems) { item in
                                ShoppingListManualRow(item: item) { isPurchased in
                                    item.isPurchased = isPurchased
                                }
                                .swipeActions(edge: .trailing) {
                                    Button(role: .destructive) {
                                        modelContext.delete(item)
                                    } label: {
                                        Label("Delete", systemImage: "trash")
                                    }
                                }
                            }
                        }
                    }
                }
            }
            .listStyle(.insetGrouped)
            .navigationTitle("Shopping List")
            .navigationDestination(for: UUID.self) { itemID in
                InventoryItemDetailView(itemID: itemID)
            }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Menu {
                        Button("Add Manual Item") {
                            showingAddManualItem = true
                        }
                        Button("Mark All Purchased") {
                            markAllPurchased()
                        }
                        Button("Clear Purchased") {
                            showingClearPurchasedConfirm = true
                        }
                    } label: {
                        Label("Actions", systemImage: "ellipsis.circle")
                    }
                }
            }
            .confirmationDialog(
                "Clear all purchased items?",
                isPresented: $showingClearPurchasedConfirm,
                titleVisibility: .visible
            ) {
                Button("Clear Purchased", role: .destructive) {
                    clearPurchased()
                }
                Button("Cancel", role: .cancel) { }
            } message: {
                Text("This will uncheck purchased items.")
            }
            .sheet(isPresented: $showingAddManualItem) {
                AddShoppingListItemView()
            }
        }
    }

    private func entry(for item: InventoryItem) -> ShoppingListItem? {
        shoppingItems.first { $0.inventoryItem?.id == item.id }
    }

    private func togglePurchased(for item: InventoryItem, isPurchased: Bool) {
        if let existing = entry(for: item) {
            existing.isPurchased = isPurchased
        } else {
            let newItem = ShoppingListItem(
                title: InventoryItemDisplay.title(for: item),
                isPurchased: isPurchased,
                isManual: false,
                inventoryItem: item
            )
            modelContext.insert(newItem)
        }
    }

    private func markAllPurchased() {
        let service = InventoryService()
        let lowStockItems = service.lowStockItems(from: inventoryItems)
        for item in lowStockItems {
            togglePurchased(for: item, isPurchased: true)
        }
        for item in shoppingItems where item.isManual {
            item.isPurchased = true
        }
    }

    private func clearPurchased() {
        for item in shoppingItems {
            item.isPurchased = false
        }
    }
}

struct ShoppingListEmptyStateView: View {
    let addManualItem: () -> Void

    var body: some View {
        ContentUnavailableView {
            Label("All Stocked", systemImage: "checkmark.circle")
        } description: {
            Text("Low stock items appear here automatically.")
        } actions: {
            Button("Add Manual Item") {
                addManualItem()
            }
        }
    }
}

struct ShoppingListInventoryRow: View {
    let item: InventoryItem
    let entry: ShoppingListItem?
    let togglePurchased: (Bool) -> Void

    var body: some View {
        let service = InventoryService()
        let isPurchased = entry?.isPurchased ?? false
        let unitsRemaining = service.unitsRemaining(for: item)

        return NavigationLink(value: item.id) {
            HStack {
                Button {
                    togglePurchased(isPurchased == false)
                } label: {
                    Label(isPurchased ? "Purchased" : "Mark", systemImage: isPurchased ? "checkmark.circle.fill" : "circle")
                }
                .buttonStyle(.borderless)
                VStack(alignment: .leading, spacing: 4) {
                    Text(InventoryItemDisplay.title(for: item))
                    if let unitsRemaining {
                        HStack(spacing: 4) {
                            Text(unitsRemaining, format: .number.precision(.fractionLength(2)))
                            Text("units remaining")
                                .foregroundStyle(.secondary)
                        }
                        .foregroundStyle(.secondary)
                    }
                }
                Spacer()
            }
        }
        .accessibilityElement(children: .combine)
    }
}

struct ShoppingListManualRow: View {
    let item: ShoppingListItem
    let togglePurchased: (Bool) -> Void

    var body: some View {
        let isPurchased = item.isPurchased

        return HStack {
            Button {
                togglePurchased(isPurchased == false)
            } label: {
                Label(isPurchased ? "Purchased" : "Mark", systemImage: isPurchased ? "checkmark.circle.fill" : "circle")
            }
            .buttonStyle(.borderless)
            VStack(alignment: .leading, spacing: 4) {
                Text(item.title)
                if item.quantity.isEmpty == false {
                    Text(item.quantity)
                        .foregroundStyle(.secondary)
                }
            }
            Spacer()
        }
        .accessibilityElement(children: .combine)
    }
}
