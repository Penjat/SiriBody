import XCTest

final class MothionHelperTests: XCTestCase {
    func testFindSortestDistance() {
        // Given
        let pidController = PIDMotionControl()
        let currentAngle = 0.0
        let targetAngle = Double.pi/2

        // When
        let shortestDistance = pidController.calculateShortestDistance(currentAngle: currentAngle, desiredHeading: targetAngle)
        let expected = Double.pi

        // Then
        XCTAssertEqual(shortestDistance, expected)
    }
}
