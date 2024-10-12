import Foundation
import Combine

class PIDRotationControl: ObservableObject {
    var bag = Set<AnyCancellable>()
    
    let proportionalRange = 1.0..<200.0
    @Published var pConstant = 76.0
    @Published var iConstant = 120.0
    @Published var dConstant = 38.0
    
    @Published var pOutput = 0.0
    @Published var iOutput = 0.0
    @Published var dOutput = 0.0
    
    @Published var pIsOn = true
    @Published var iIsOn = true
    @Published var dIsOn = true
    
    @Published var maxSpeed = 95.0
    
    @Published var targetYaw = 0.0
    
    private var integralError: Double = 0.0
    private var lastError: Double = 0.0
    private var lastTime: Date?
    
    init() {
        $targetYaw.sink { _ in
            self.integralError = 0.0
            self.lastError = 0.0
        }.store(in: &bag)
    }
    
    func findClosestRotation(targetYaw: Double, currentYaw: Double) -> Double {
        let difference = targetYaw - currentYaw
        let shortestAngle = atan2(sin(difference), cos(difference))
        return shortestAngle
    }
    
    func motorOutput(currentYaw: Double) -> Double {
        guard !approximatelyEqual(targetYaw, currentYaw, tolerance: 0.05) else {
            pOutput = 0
            iOutput = 0
            dOutput = 0
            integralError = 0
            lastError = 0
            return 0
        }
        
        let error = findClosestRotation(targetYaw: targetYaw, currentYaw: currentYaw)
        
        pOutput = pIsOn ? (error * pConstant) : 0
        
        let currentTime = Date()
        if let lastTime = lastTime {
            let deltaTime = currentTime.timeIntervalSince(lastTime)
            integralError += error * deltaTime
            iOutput = iIsOn ? (integralError * iConstant) : 0
            
            let derivative = (error - lastError) / deltaTime
            dOutput = dIsOn ? (derivative * dConstant) : 0
            lastError = error
        }
        lastTime = currentTime
        
        let output = pOutput + iOutput + dOutput
        return max(-maxSpeed, min(maxSpeed, output))
    }
}
