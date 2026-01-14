import Foundation
import SwiftData

@Model
final class InventoryFieldDefinition {
    var id: UUID
    var name: String
    var type: InventoryFieldType
    var pickerOptions: [String]?
    var order: Int

    init(
        id: UUID = UUID(),
        name: String,
        type: InventoryFieldType = .text,
        pickerOptions: [String]? = nil,
        order: Int = 0
    ) {
        self.id = id
        self.name = name
        self.type = type
        self.pickerOptions = pickerOptions
        self.order = order
    }
}
