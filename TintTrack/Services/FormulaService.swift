import Foundation

struct FormulaService {
    struct InsufficientItem: @unchecked Sendable {
        let item: InventoryItem
        let requiredGrams: Double
        let availableGrams: Double
    }

    enum FormulaServiceError: Error, @unchecked Sendable {
        case insufficientStock([InsufficientItem])
        case archivedItemUsed
    }

    func deductInventory(
        for lineItems: [FormulaLineItem],
        visit: Visit?,
        allowNegative: Bool
    ) throws -> [InventoryTransaction] {
        var totalsById: [UUID: (InventoryItem, Double)] = [:]

        for lineItem in lineItems {
            guard let item = lineItem.inventoryItem else {
                continue
            }
            if item.isArchived {
                throw FormulaServiceError.archivedItemUsed
            }
            let amount = max(0, lineItem.amountUsedGrams)
            if let existing = totalsById[item.id] {
                totalsById[item.id] = (existing.0, existing.1 + amount)
            } else {
                totalsById[item.id] = (item, amount)
            }
        }

        var insufficient: [InsufficientItem] = []
        for (_, entry) in totalsById {
            let item = entry.0
            let required = entry.1
            let available = item.currentStockGrams
            if allowNegative == false, available - required < 0 {
                insufficient.append(
                    InsufficientItem(
                        item: item,
                        requiredGrams: required,
                        availableGrams: available
                    )
                )
            }
        }

        if insufficient.isEmpty == false {
            throw FormulaServiceError.insufficientStock(insufficient)
        }

        var transactions: [InventoryTransaction] = []
        for (_, entry) in totalsById {
            let item = entry.0
            let required = entry.1
            item.currentStockGrams -= required
            let transaction = InventoryTransaction(
                inventoryItem: item,
                date: Date(),
                deltaGrams: -required,
                reason: .visit,
                relatedVisit: visit
            )
            transactions.append(transaction)
        }

        return transactions
    }
}
