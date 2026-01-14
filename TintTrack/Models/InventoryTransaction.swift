import Foundation
import SwiftData

@Model
final class InventoryTransaction {
    var id: UUID
    var inventoryItem: InventoryItem?
    var date: Date
    var deltaGrams: Double
    var reason: TransactionReason
    var relatedVisit: Visit?

    init(
        id: UUID = UUID(),
        inventoryItem: InventoryItem? = nil,
        date: Date = Date(),
        deltaGrams: Double,
        reason: TransactionReason,
        relatedVisit: Visit? = nil
    ) {
        self.id = id
        self.inventoryItem = inventoryItem
        self.date = date
        self.deltaGrams = deltaGrams
        self.reason = reason
        self.relatedVisit = relatedVisit
    }
}
