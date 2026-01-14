import Foundation
import SwiftData

@Model
final class Formula {
    var id: UUID
    var name: String
    var visit: Visit?
    var lineItems: [FormulaLineItem]?

    init(
        id: UUID = UUID(),
        name: String,
        visit: Visit? = nil,
        lineItems: [FormulaLineItem]? = []
    ) {
        self.id = id
        self.name = name
        self.visit = visit
        self.lineItems = lineItems
    }
}
