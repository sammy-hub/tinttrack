import SwiftUI
import SwiftData

struct InventoryCategoryDetailView: View {
    @Query private var categories: [InventoryCategory]
    @Query private var items: [InventoryItem]
    @Query(sort: \AppSettings.id) private var settingsList: [AppSettings]
    @Environment(SubscriptionService.self) private var subscriptionService

    let categoryID: UUID

    @State private var showingQuickAdd = false
    @State private var showingBulkAddShades = false
    @State private var showingPaywall = false

    init(categoryID: UUID) {
        self.categoryID = categoryID
        _categories = Query(filter: #Predicate { $0.id == categoryID })
        _items = Query(filter: #Predicate { $0.category?.id == categoryID }, sort: \InventoryItem.id)
    }

    var body: some View {
        let title = categories.first?.name ?? "Category"
        let isHairColor = title.localizedCaseInsensitiveContains("hair color")
        let debugBypass = settingsList.first?.debugBypassSubscription ?? false

        List {
            if items.isEmpty {
                Section {
                    InventoryCategoryEmptyStateView(action: {
                        showingQuickAdd = true
                    })
                }
            } else {
                Section {
                    ForEach(items) { item in
                        NavigationLink(value: item.id) {
                            InventoryItemRow(item: item)
                        }
                    }
                }
            }
        }
        .listStyle(.insetGrouped)
        .navigationTitle(title)
        .navigationDestination(for: UUID.self) { itemID in
            InventoryItemDetailView(itemID: itemID)
        }
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                let canCreate = subscriptionService.isSubscribed || debugBypass
                if isHairColor {
                    Menu {
                        Button("Add Item") {
                            if canCreate {
                                showingQuickAdd = true
                            } else {
                                showingPaywall = true
                            }
                        }
                        Button("Add Shades") {
                            if canCreate {
                                showingBulkAddShades = true
                            } else {
                                showingPaywall = true
                            }
                        }
                    } label: {
                        Label("Add", systemImage: "plus")
                    }
                } else {
                    Button {
                        if canCreate {
                            showingQuickAdd = true
                        } else {
                            showingPaywall = true
                        }
                    } label: {
                        Label("Add Item", systemImage: "plus")
                    }
                }
            }
        }
        .sheet(isPresented: $showingQuickAdd) {
            if let category = categories.first {
                QuickAddInventoryItemView(category: category)
            } else {
                ContentUnavailableView {
                    Label("Category Missing", systemImage: "exclamationmark.triangle")
                } description: {
                    Text("This category is no longer available.")
                }
            }
        }
        .sheet(isPresented: $showingBulkAddShades) {
            if let category = categories.first {
                BulkAddShadesView(category: category)
            } else {
                ContentUnavailableView {
                    Label("Category Missing", systemImage: "exclamationmark.triangle")
                } description: {
                    Text("This category is no longer available.")
                }
            }
        }
        .sheet(isPresented: $showingPaywall) {
            PaywallView {
                showingPaywall = false
            }
        }
    }
}

struct InventoryCategoryEmptyStateView: View {
    let action: () -> Void

    var body: some View {
        ContentUnavailableView {
            Label("No Items", systemImage: "shippingbox")
        } description: {
            Text("Add an item to start tracking stock.")
        } actions: {
            Button("Add Item") {
                action()
            }
        }
    }
}
