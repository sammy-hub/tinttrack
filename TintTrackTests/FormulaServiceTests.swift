import XCTest
@testable import TintTrack

final class FormulaServiceTests: XCTestCase {
    func testDeductInventoryCreatesTransaction() throws {
        let service = FormulaService()
        let item = InventoryItem(currentStockGrams: 100, lowStockThresholdGrams: 10)
        let lineItem1 = FormulaLineItem(inventoryItem: item, amountUsedGrams: 30)
        let lineItem2 = FormulaLineItem(inventoryItem: item, amountUsedGrams: 10)

        let transactions = try service.deductInventory(
            for: [lineItem1, lineItem2],
            visit: nil,
            allowNegative: false
        )

        XCTAssertEqual(item.currentStockGrams, 60, accuracy: 0.0001)
        XCTAssertEqual(transactions.count, 1)
        XCTAssertEqual(transactions.first?.deltaGrams ?? 0, -40, accuracy: 0.0001)
    }

    func testDeductInventoryBlocksNegativeWhenNotAllowed() {
        let service = FormulaService()
        let item = InventoryItem(currentStockGrams: 5, lowStockThresholdGrams: 1)
        let lineItem = FormulaLineItem(inventoryItem: item, amountUsedGrams: 10)

        do {
            _ = try service.deductInventory(
                for: [lineItem],
                visit: nil,
                allowNegative: false
            )
            XCTFail("Expected insufficient stock error")
        } catch let error as FormulaService.FormulaServiceError {
            switch error {
            case .insufficientStock:
                break
            default:
                XCTFail("Unexpected error")
            }
        } catch {
            XCTFail("Unexpected error")
        }
    }
}
