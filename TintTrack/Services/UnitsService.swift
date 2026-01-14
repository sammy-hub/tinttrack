import Foundation

struct UnitsService {
    private static let gramsPerOunce: Double = 28.349523125

    func grams(from value: Double, unit: Units) -> Double {
        switch unit {
        case .grams:
            return value
        case .ounces:
            return value * Self.gramsPerOunce
        }
    }

    func displayValue(fromGrams grams: Double, unit: Units) -> Double {
        switch unit {
        case .grams:
            return grams
        case .ounces:
            return grams / Self.gramsPerOunce
        }
    }
}
