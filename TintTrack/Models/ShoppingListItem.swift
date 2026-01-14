import Foundation
import SwiftData

@Model
final class ShoppingListItem {
    var id: UUID
    var title: String
    var quantity: String
    var isPurchased: Bool
    var createdAt: Date
    var isManual: Bool
    var inventoryItem: InventoryItem?

    init(
        id: UUID = UUID(),
        title: String,
        quantity: String = "",
        isPurchased: Bool = false,
        createdAt: Date = Date(),
        isManual: Bool,
        inventoryItem: InventoryItem? = nil
    ) {
        self.id = id
        self.title = title
        self.quantity = quantity
        self.isPurchased = isPurchased
        self.createdAt = createdAt
        self.isManual = isManual
        self.inventoryItem = inventoryItem
    }
}
