import Foundation
import Combine

struct PIDOutput {
    let p: Double
    let i: Double
    let d: Double
    let combined: Double
}

class PIDController: ObservableObject {
    
    @Published var maxValue = 254.0
    @Published var pConstant = 400.0
    @Published var iConstant = 0.0
    @Published var dConstant = 0.0

    @Published var pIsOn = true
    @Published var iIsOn = true
    @Published var dIsOn = true

    private var integralError: Double = 0.0
    private var lastError: Double = 0.0
    
    @Published var lastUpdateTime: Date?

    var bag = Set<AnyCancellable>()

    func resetError() {
        integralError = 0.0
        lastError = 0.0
        lastUpdateTime = .now
    }

    func output(_ error: Double) -> PIDOutput {

        let currentTime = Date()
        let deltaTime: Double
        if let lastTime = lastUpdateTime {
            deltaTime = currentTime.timeIntervalSince(lastTime)
        } else {
            deltaTime = 0.0
        }
        lastUpdateTime = currentTime

        integralError += error * deltaTime
        let derivativeError = deltaTime > 0 ? (error - lastError) / deltaTime : 0.0

        let pOutput = (pIsOn ? pConstant * error : 0.0)
        let iOutput = (iIsOn ? iConstant * integralError : 0.0)
        let dOutput = (dIsOn ? dConstant * derivativeError : 0.0)
        let combined = max(min((pOutput + iOutput + dOutput), maxValue), -maxValue)

        return PIDOutput(
            p: pOutput,
            i: iOutput,
            d: dOutput,
            combined: combined)
    }
}
