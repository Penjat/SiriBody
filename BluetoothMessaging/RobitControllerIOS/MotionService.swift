import Foundation
import CoreMotion
import Combine

enum Goal {
    case turnTo(angle: Double)
    case driveTo(angle: Double, leftSpeed: Double, rightSpeed: Double)
    case driveFor(time: Double)
    case idle
}

class MotionService {
    let motionManager = CMMotionManager()
    
    let motionStatePublisher = CurrentValueSubject<MotionState, Never>(.stopped)
    let positionPublisher = PassthroughSubject<CMDeviceMotion, Never>()
    let goal = CurrentValueSubject<Goal, Never>(.idle)
    
    var bag = Set<AnyCancellable>()

    init() {
        motionManager.accelerometerUpdateInterval = 0.1
        motionManager.startDeviceMotionUpdates(to: OperationQueue.main) { (data, error) in
            guard let data = data else {
                return
            }
            
            switch self.goal.value {
            case .turnTo(angle: let angle):
                if abs(data.attitude.yaw-angle) < 0.05 {
                    self.motionStatePublisher.send(.stopped)
                }
            case .driveTo(angle: let angle, leftSpeed: _, rightSpeed: _):
                if abs(data.attitude.yaw-angle) < 0.05 {
                    self.motionStatePublisher.send(.stopped)
                }
            case .driveFor(time: let time):
                //TODO: check time
                return
            case .idle:
                return
            }
            self.positionPublisher.send(data)
        }
        
        goal.withLatestFrom(positionPublisher).sink { (newGoal, position) in
            // TODO: this will get smarter later
            switch newGoal {
                
            case .turnTo(angle: let angle):
                if position.attitude.yaw < angle {
                    self.motionStatePublisher.send(.turningRight)
                } else {
                    self.motionStatePublisher.send(.turningLeft)
                }
            case .driveTo(angle: _, leftSpeed: let leftSpeed, rightSpeed: let rightSpeed):
                self.motionStatePublisher.send(MotionState(leftSpeed: leftSpeed, rightSpeed: rightSpeed))
            case .driveFor(time: let time):
                //TODO: write time drive code
                return
            case .idle:
                self.motionStatePublisher.send(.stopped)
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
        MotionState(leftSpeed: -60.0, rightSpeed: 60.0)
    }
    
    static var turningRight: MotionState {
        MotionState(leftSpeed: 60.0, rightSpeed: -60.0)
    }
}
