import Foundation

struct DraftLineItem: Identifiable, Hashable {
    let id: UUID
    var inventoryItem: InventoryItem
    var amountGrams: Double

    init(id: UUID = UUID(), inventoryItem: InventoryItem, amountGrams: Double) {
        self.id = id
        self.inventoryItem = inventoryItem
        self.amountGrams = amountGrams
    }
}
