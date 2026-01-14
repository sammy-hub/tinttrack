import Foundation

enum InventoryFieldType: String, Codable, CaseIterable {
    case text
    case number
    case toggle
    case picker
    case barcode
}
