import Foundation
import SwiftData

@Model
final class InventoryCategory {
    var id: UUID
    var name: String
    var fieldDefinitions: [InventoryFieldDefinition]?
    var isSystem: Bool

    init(
        id: UUID = UUID(),
        name: String,
        fieldDefinitions: [InventoryFieldDefinition]? = [],
        isSystem: Bool = false
    ) {
        self.id = id
        self.name = name
        self.fieldDefinitions = fieldDefinitions
        self.isSystem = isSystem
    }
}
