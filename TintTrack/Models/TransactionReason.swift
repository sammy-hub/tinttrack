import Foundation

enum TransactionReason: String, Codable, CaseIterable {
    case visit
    case manualAdjustment
}
