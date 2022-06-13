import Foundation
import CoreMotion
import Combine

enum Goal {
    case turnTo(angle: Double)
    case driveTo(angle: Double, leftSpeed: Double, rightSpeed: Double)
    case driveFor(time: Double, leftSpeed: Double, rightSpeed: Double)
    case idle
    case waitFor(time: Double)
}

class MotionService {
    let motionManager = CMMotionManager()
    
    let motionStatePublisher = CurrentValueSubject<MotionState, Never>(.stopped)
    let positionPublisher = PassthroughSubject<CMDeviceMotion, Never>()
    let goal = CurrentValueSubject<Goal, Never>(.idle)
    
    var bag = Set<AnyCancellable>()
    
    let goalSeq = [Goal.turnTo(angle: 0.0), Goal.driveFor(time: 1.0, leftSpeed: 60.0, rightSpeed: 60.0), Goal.waitFor(time: 1.0), Goal.turnTo(angle: Double.pi), Goal.waitFor(time: 1.0), Goal.driveFor(time: 1.0, leftSpeed: 60.0, rightSpeed: 60.0), Goal.waitFor(time: 1.0),]
    
    var index = 0

    init() {
        motionManager.accelerometerUpdateInterval = 0.1
        motionManager.startDeviceMotionUpdates(to: OperationQueue.main) { (data, error) in
            guard let data = data else {
                return
            }
            
            switch self.goal.value {
            case .turnTo(angle: let angle):
                if abs(data.attitude.yaw-angle) < 0.05 {
                    self.done()
                }
            case .driveTo(angle: let angle, leftSpeed: _, rightSpeed: _):
                if abs(data.attitude.yaw-angle) < 0.05 {
                    self.done()
                }
            case .driveFor(time: let time, _, _):
                if time < Date.timeIntervalSinceReferenceDate {
                    self.done()
                }
            case .idle:
                return
            case .waitFor(time: let time):
                if time < Date.timeIntervalSinceReferenceDate {
                    self.done()
                }
            }
            self.positionPublisher.send(data)
        }
        
        goal.withLatestFrom(positionPublisher).sink { (newGoal, position) in
            // TODO: this will get smarter later
            switch newGoal {
                
            case .turnTo(angle: let angle):
                print("turn to \(angle)")
                if position.attitude.yaw < angle {
                    self.motionStatePublisher.send(.turningRight)
                } else {
                    self.motionStatePublisher.send(.turningLeft)
                }
            case .driveTo(angle: _, leftSpeed: let leftSpeed, rightSpeed: let rightSpeed):
                print("drive to")
                self.motionStatePublisher.send(MotionState(leftSpeed: leftSpeed, rightSpeed: rightSpeed))
            case .driveFor(time: _):
                print("drive for")
                self.motionStatePublisher.send(MotionState(leftSpeed: 100, rightSpeed: 100))
            case .idle:
                print("idle")
                self.motionStatePublisher.send(.stopped)
            case .waitFor(time: let time):
                print("wait for \(time)")
                self.motionStatePublisher.send(.stopped)
            }
        }.store(in: &bag)
    }
    
    func done() {
        goal.send(.idle)
//        goal.send(goalSeq.map({ goal in
//            switch goal {
//            case .waitFor(time: let time):
//                return Goal.waitFor(time: time + Date.timeIntervalSinceReferenceDate)
//            case .driveFor(time: let time):
//                return Goal.driveFor(time: time + Date.timeIntervalSinceReferenceDate)
//            default:
//                return goal
//            }
//        })[index%goalSeq.count])
        index += 1
    }
}

struct MotionState {
    let leftSpeed: Double
    let rightSpeed: Double
    
    static var stopped: MotionState {
        MotionState(leftSpeed: 0.0, rightSpeed: 0.0)
    }
    
    static var turningLeft: MotionState {
        MotionState(leftSpeed: 100.0, rightSpeed: -100.0)
    }
    
    static var turningRight: MotionState {
        MotionState(leftSpeed: -100.0, rightSpeed: 100.0)
    }
}
