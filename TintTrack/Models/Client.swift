import Foundation
import SwiftData

@Model
final class Client {
    var id: UUID
    var name: String
    var createdAt: Date
    var visits: [Visit]?

    init(
        id: UUID = UUID(),
        name: String,
        createdAt: Date = Date(),
        visits: [Visit]? = []
    ) {
        self.id = id
        self.name = name
        self.createdAt = createdAt
        self.visits = visits
    }
}
