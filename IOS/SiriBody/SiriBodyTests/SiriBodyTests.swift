import XCTest

final class SiriBodyTests: XCTestCase {

    func testPIDRotationControlFindsClosestRotation() {
        // given
        let targetYaw1 = 2.0
        let currentYaw1 = 0.0
        
        let targetYaw2 = 3.0
        let currentYaw2 = -3.0
        
        let targetYaw3 = 3.12
        let currentYaw3 = -3.12
        
        let controller = PIDRotationControl()
        
        // when
        let errorDistance1 = controller.findClosestRotation(targetYaw: targetYaw1, currentYaw: currentYaw1)
        let errorDistance2 = controller.findClosestRotation(targetYaw: targetYaw2, currentYaw: currentYaw2)
        let errorDistance3 = controller.findClosestRotation(targetYaw: targetYaw3, currentYaw: currentYaw3)
        
        // then
        XCTAssertEqual(errorDistance1, 2)
        XCTAssertEqual(errorDistance2,  .pi - 6.0 )
        XCTAssertEqual(errorDistance3,  -0.04)
        
        XCTAssertTrue(abs(errorDistance2) < .pi)
        XCTAssertTrue(abs(errorDistance3) < .pi)
    }

}
