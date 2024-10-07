import Foundation
import CoreMotion
import Combine

class MotionService: ObservableObject {
    let motionManager = CMMotionManager()
    @Published var position: CMDeviceMotion?
    @Published var acceleration: CMAccelerometerData?
    
    init() {
        startAccelerationUpdates()
        startPositionUpdates()
        
    }
    
    func startAccelerationUpdates() {
        motionManager.accelerometerUpdateInterval = 0.01
        motionManager.startAccelerometerUpdates(to: .main) { [weak self] (acceleration, error) in
            guard let acceleration, error == nil else {
                return
            }
            self?.acceleration = acceleration
        }
    }
    
    func startPositionUpdates() {
        motionManager.accelerometerUpdateInterval = 0.1
        motionManager.startDeviceMotionUpdates(to: .main) { [weak self] (position, error) in
            guard let position else {
                return
            }
            self?.position = position
        }
    }
}
