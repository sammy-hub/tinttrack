import Foundation
import SwiftData

@Model
final class AppSettings {
    var id: UUID
    var preferredUnits: Units
    var stepSizeGrams: Double
    var stepSizeOunces: Double
    var iCloudEnabled: Bool
    var hasCompletedOnboarding: Bool?
    var debugBypassSubscription: Bool?

    init(
        id: UUID = UUID(),
        preferredUnits: Units = .grams,
        stepSizeGrams: Double = 5,
        stepSizeOunces: Double = 0.1,
        iCloudEnabled: Bool = false,
        hasCompletedOnboarding: Bool? = false,
        debugBypassSubscription: Bool? = nil
    ) {
        self.id = id
        self.preferredUnits = preferredUnits
        self.stepSizeGrams = stepSizeGrams
        self.stepSizeOunces = stepSizeOunces
        self.iCloudEnabled = iCloudEnabled
        self.hasCompletedOnboarding = hasCompletedOnboarding
        self.debugBypassSubscription = debugBypassSubscription
    }
}
