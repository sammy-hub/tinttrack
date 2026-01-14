import Foundation

struct InventoryService {
    func isLowStock(_ item: InventoryItem) -> Bool {
        guard item.isArchived == false else {
            return false
        }
        return item.currentStockGrams <= item.lowStockThresholdGrams
    }

    func lowStockItems(from items: [InventoryItem]) -> [InventoryItem] {
        items.filter { isLowStock($0) }
    }

    func unitsRemaining(for item: InventoryItem) -> Double? {
        guard item.unitSizeGrams > 0 else {
            return nil
        }
        return item.currentStockGrams / item.unitSizeGrams
    }

    func lowStockThresholdUnits(for item: InventoryItem) -> Double? {
        guard item.unitSizeGrams > 0 else {
            return nil
        }
        return item.lowStockThresholdGrams / item.unitSizeGrams
    }

    func costForUsage(item: InventoryItem, amountGrams: Double) -> Double? {
        guard item.unitSizeGrams > 0 else {
            return nil
        }
        guard let costText = item.fieldValues[InventoryFieldKeys.cost],
              let costPerUnit = Double(costText) else {
            return nil
        }
        let normalizedAmount = max(0, amountGrams)
        let costPerGram = costPerUnit / item.unitSizeGrams
        return normalizedAmount * costPerGram
    }
}
