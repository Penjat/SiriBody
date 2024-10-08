import Foundation
import Combine

class PIDRotationControl: ObservableObject {
    var bag = Set<AnyCancellable>()
    
    let proportionalRange = 1.0..<200.0
    @Published var pConstant = 20.0
    @Published var iConstant = 0.05
    @Published var dConstant = 20.0
    
    @Published var pOutput = 0.0
    @Published var iOutput = 0.0
    @Published var dOutput = 0.0
    
    @Published var pIsOn = true
    @Published var iIsOn = true // Set to true for integral calculation
    @Published var dIsOn = true
    
    @Published var maxSpeed = 254.0
    
    @Published var targetYaw = 0.0
    
    private var integralError: Double = 0.0
    private var lastError: Double = 0.0
    private var lastTime: Date?
    
    init() {
        $targetYaw.sink { _ in
            // Reset errors when the target yaw changes
            self.integralError = 0.0
            self.lastError = 0.0
        }.store(in: &bag)
    }
    
    func findClosestRotation(targetYaw: Double, currentYaw: Double) -> Double  {
        let distance = targetYaw - currentYaw
        return abs(distance) > .pi ? distance.truncatingRemainder(dividingBy: .pi) * -1 : distance
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
        
        // Proportional term
        pOutput = pIsOn ? (error * pConstant) : 0
        
        // Integral term
        let currentTime = Date()
        if let lastTime = lastTime {
            let deltaTime = currentTime.timeIntervalSince(lastTime)
            integralError += error * deltaTime
            iOutput = iIsOn ? (integralError * iConstant) : 0
            
            // Derivative term
            let derivative = (error - lastError) / deltaTime
            dOutput = dIsOn ? (derivative * dConstant) : 0
            
            // Update lastError for the next derivative calculation
            lastError = error
        }
        lastTime = currentTime
        
        // Sum the outputs and constrain to maxSpeed
        let output = pOutput + iOutput + dOutput
        return max(-maxSpeed, min(maxSpeed, output))
    }
}
