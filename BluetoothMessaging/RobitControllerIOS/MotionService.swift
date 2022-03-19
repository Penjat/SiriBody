import Foundation
import CoreMotion
import Combine

class MotionService {
    let motionManager = CMMotionManager()
    
    let motionStatePublisher = CurrentValueSubject<MotionState, Never>(.stopped)
    let positionPublisher = PassthroughSubject<CMDeviceMotion, Never>()
    let goal = CurrentValueSubject<Double, Never>(0.0)
    
    var bag = Set<AnyCancellable>()

    init() {
        motionManager.accelerometerUpdateInterval = 0.5
        motionManager.startDeviceMotionUpdates(to: OperationQueue.main) { (data, error) in
            guard let data = data else {
                return
            }
            self.positionPublisher.send(data)
            
            guard self.motionStatePublisher.value != .stopped else {
                return
            }
            
            if abs(data.attitude.yaw) < 0.05 {
                self.motionStatePublisher.send(.stopped)
            }
        }
        
        goal.sink { newGoal in
            // TODO: this will get smarter later
            self.motionStatePublisher.send(.turningLeft)
        }.store(in: &bag)
        
    }
}

enum MotionState {
    case turningLeft
    case stopped
}
