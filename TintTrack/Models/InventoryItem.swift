import Foundation
import SwiftData

@Model
final class InventoryItem {
    var id: UUID
    var category: InventoryCategory?
    var fieldValues: [String: String]
    var currentStockGrams: Double
    var lowStockThresholdGrams: Double
    var unitSizeGrams: Double
    var isArchived: Bool

    init(
        id: UUID = UUID(),
        category: InventoryCategory? = nil,
        fieldValues: [String: String] = [:],
        currentStockGrams: Double = 0,
        lowStockThresholdGrams: Double = 0,
        unitSizeGrams: Double = 0,
        isArchived: Bool = false
    ) {
        self.id = id
        self.category = category
        self.fieldValues = fieldValues
        self.currentStockGrams = currentStockGrams
        self.lowStockThresholdGrams = lowStockThresholdGrams
        self.unitSizeGrams = unitSizeGrams
        self.isArchived = isArchived
    }
}
