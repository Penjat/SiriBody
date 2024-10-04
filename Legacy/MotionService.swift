import Foundation
import CoreMotion
import Combine

class MotionService {
    let motionManager = CMMotionManager()
    let positionPublisher = PassthroughSubject<CMDeviceMotion, Never>()

    var bag = Set<AnyCancellable>()

    init() {
        motionManager.accelerometerUpdateInterval = 0.1
        motionManager.startDeviceMotionUpdates(to: OperationQueue.main) { (data, error) in
            guard let data = data else {
                return
            }
        }
    }
}
