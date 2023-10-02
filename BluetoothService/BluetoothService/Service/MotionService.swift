import Foundation
import CoreMotion
import Combine

class MotionService {
    let motionManager = CMMotionManager()
    let positionPublisher = PassthroughSubject<CMDeviceMotion, Never>()
    let accelerationPublisher = PassthroughSubject<CMAccelerometerData, Never>()

    init() {
        motionManager.accelerometerUpdateInterval = 0.2
        motionManager.startDeviceMotionUpdates(to: .main) { [weak self] (data, error) in
            guard let data = data else {
                return
            }
            self?.positionPublisher.send(data)
        }

//        motionManager.accelerometerUpdateInterval = 0.01
//        motionManager.startAccelerometerUpdates(to: .main) { [weak self] (data, error) in
//                guard let data = data, error == nil else {
//                    return
//                }
//            self?.accelerationPublisher.send(data)
//            }

    }
}
