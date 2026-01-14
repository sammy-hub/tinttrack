import Foundation
import SwiftData

@Model
final class Visit {
    var id: UUID
    var date: Date
    var client: Client?
    var formulas: [Formula]?
    var notes: String?

    init(
        id: UUID = UUID(),
        date: Date = Date(),
        client: Client? = nil,
        formulas: [Formula]? = [],
        notes: String? = nil
    ) {
        self.id = id
        self.date = date
        self.client = client
        self.formulas = formulas
        self.notes = notes
    }
}
