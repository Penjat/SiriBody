import Foundation
import CoreMotion
import Combine

enum Goal {
    case turnTo(angle: Double)
    case driveTo(angle: Double, leftSpeed: Double, rightSpeed: Double)
    case driveFor(time: Double)
}

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
            
            if abs(data.attitude.yaw-self.goal.value) < 0.05 {
                self.motionStatePublisher.send(.stopped)
            }
        }
        
        goal.withLatestFrom(positionPublisher).sink { (newGoal, position) in
            // TODO: this will get smarter later
            if position.attitude.yaw < newGoal {
                self.motionStatePublisher.send(.turningLeft)
            } else {
                self.motionStatePublisher.send(.turningRight)
            }
        }.store(in: &bag)
    }
}

struct MotionState {
    let leftSpeed: Double
    let rightSpeed: Double
    
    static var stopped: MotionState {
        MotionState(leftSpeed: 0.0, rightSpeed: 0.0)
    }
    
    static var turningLeft: MotionState {
        MotionState(leftSpeed: 60.0, rightSpeed: -60.0)
    }
    
    static var turningRight: MotionState {
        MotionState(leftSpeed: -60.0, rightSpeed: 60.0)
    }
}
