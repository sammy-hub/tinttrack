import Foundation
import SwiftData

@Model
final class FormulaLineItem {
    var id: UUID
    var inventoryItem: InventoryItem?
    var amountUsedGrams: Double

    init(
        id: UUID = UUID(),
        inventoryItem: InventoryItem? = nil,
        amountUsedGrams: Double = 0
    ) {
        self.id = id
        self.inventoryItem = inventoryItem
        self.amountUsedGrams = amountUsedGrams
    }
}
