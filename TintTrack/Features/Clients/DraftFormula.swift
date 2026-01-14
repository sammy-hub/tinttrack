import Foundation

struct DraftFormula: Identifiable, Hashable {
    let id: UUID
    var name: String
    var lineItems: [DraftLineItem]

    init(id: UUID = UUID(), name: String = "", lineItems: [DraftLineItem] = []) {
        self.id = id
        self.name = name
        self.lineItems = lineItems
    }
}
