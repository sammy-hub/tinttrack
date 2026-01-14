import XCTest
@testable import TintTrack

final class UnitsServiceTests: XCTestCase {
    func testGramsRoundTripFromOunces() {
        let service = UnitsService()
        let grams: Double = 100
        let ounces = service.displayValue(fromGrams: grams, unit: .ounces)
        let roundTrip = service.grams(from: ounces, unit: .ounces)
        XCTAssertEqual(roundTrip, grams, accuracy: 0.0001)
    }

    func testGramsDisplayInGrams() {
        let service = UnitsService()
        let grams: Double = 55
        let display = service.displayValue(fromGrams: grams, unit: .grams)
        XCTAssertEqual(display, grams, accuracy: 0.0001)
    }
}
