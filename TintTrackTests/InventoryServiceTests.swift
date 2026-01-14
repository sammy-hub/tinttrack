import XCTest
@testable import TintTrack

final class InventoryServiceTests: XCTestCase {
    func testLowStockDetection() {
        let service = InventoryService()
        let lowItem = InventoryItem(currentStockGrams: 10, lowStockThresholdGrams: 10)
        let okItem = InventoryItem(currentStockGrams: 25, lowStockThresholdGrams: 10)
        let archivedItem = InventoryItem(currentStockGrams: 5, lowStockThresholdGrams: 10, isArchived: true)

        let lowStock = service.lowStockItems(from: [lowItem, okItem, archivedItem])

        XCTAssertEqual(lowStock.count, 1)
        XCTAssertEqual(lowStock.first?.id, lowItem.id)
    }

    func testCostForUsageFromUnitCost() {
        let service = InventoryService()
        let item = InventoryItem(
            fieldValues: [InventoryFieldKeys.cost: "10"],
            currentStockGrams: 0,
            lowStockThresholdGrams: 0,
            unitSizeGrams: 50,
            isArchived: false
        )

        let cost = service.costForUsage(item: item, amountGrams: 25)

        XCTAssertNotNil(cost)
        XCTAssertEqual(cost ?? 0, 5, accuracy: 0.0001)
    }
}
