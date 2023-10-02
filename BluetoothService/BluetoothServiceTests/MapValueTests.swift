import XCTest

class MapValueTests: XCTestCase {

    func testMapValueWithinBounds() {
        // Test a value within bounds (inputValue = 0.5)
        let mappedValue = Note.mapValue(0.5, 0.0, 1.0, 60.0, 72.0)
        XCTAssertEqual(mappedValue, 66.0, accuracy: 0.01)
    }

    func testMapValueLowerBound() {
        // Test the lower bound (inputValue = 0.0)
        let mappedValue = Note.mapValue(0.0, 0.0, 1.0, 60.0, 72.0)
        XCTAssertEqual(mappedValue, 60.0, accuracy: 0.01)
    }

    func testMapValueUpperBound() {
        // Test the upper bound (inputValue = 1.0)
        let mappedValue = Note.mapValue(1.0, 0.0, 1.0, 60.0, 72.0)
        XCTAssertEqual(mappedValue, 72.0, accuracy: 0.01)
    }

    func testMapValueOutsideBounds() {
        // Test a value outside bounds (inputValue = -1.0)
        let mappedValue = Note.mapValue(-1.0, 0.0, 1.0, 60.0, 72.0)
        XCTAssertEqual(mappedValue, 60.0, accuracy: 0.01)
    }

}


