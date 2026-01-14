import Foundation

struct InventoryItemDisplay {
    static func title(for item: InventoryItem) -> String {
        item.fieldValues[InventoryFieldKeys.title] ?? "Untitled"
    }

    static func secondaryLine(for item: InventoryItem) -> String? {
        let brand = item.fieldValues[InventoryFieldKeys.brand]
        let line = item.fieldValues[InventoryFieldKeys.productLine]
        if let brand, brand.isEmpty == false, let line, line.isEmpty == false {
            return "\(brand) · \(line)"
        }
        if let brand, brand.isEmpty == false {
            return brand
        }
        if let line, line.isEmpty == false {
            return line
        }
        return nil
    }
}
