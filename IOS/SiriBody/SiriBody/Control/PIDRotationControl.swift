import Foundation
import Combine

class PIDRotationControl: ObservableObject {
    let proportionaRange = 1.0..<200.0
    @Published var pConstant = 20.0
    @Published var iConstant = 20.0
    @Published var dConstant = 20.0
    
    @Published var pOutput = 0.0
    @Published var iOutput = 0.0
    @Published var dOutput = 0.0
    
    @Published var pIsOn = true
    @Published var iIsOn = false
    @Published var dIsOn = false
    
    @Published var maxSpeed = 254.0
    
    var lastTime: Date?
    // Given:
    // +goal (targetYaw)
    // +new goal resets all previous error data (?)
    // +currentYaw
    
    // function takes the currentYaw and the target yaw
    // calculates the shorter distance around
    // outputs the motor speed based on PID
    
    func findClosestRotation(targetYaw: Double, currentYaw: Double) -> Double  {
        let distance = targetYaw-currentYaw
        return abs(distance) > .pi ? distance.truncatingRemainder(dividingBy: .pi)*(-1) : distance
    }
    
    func motorOutput(targetYaw: Double, currentYaw: Double) -> Double {

        guard !approximatelyEqual(targetYaw, currentYaw, tolerance: 0.02) else {
            pOutput = 0
            iOutput = 0
            dOutput = 0
            return 0
        }
        
        let error = findClosestRotation(targetYaw: targetYaw, currentYaw: currentYaw)
        
        pOutput = (pIsOn ? (error * pConstant) : 0)
        
        return  pOutput// + Integral + Derivative
    }
}
