import Foundation
import Combine

class PIDController: ObservableObject {
    @Published var outputRange = -1...1

    @Published var isEnabled = true

    @Published var pConstant = 0.0
    @Published var iConstant = 0.0
    @Published var dConstant = 0.0

    @Published var pIsOn = true
    @Published var iIsOn = true
    @Published var dIsOn = true

    @Published var pOutput = 0.0
    @Published var iOutput = 0.0
    @Published var dOutput = 0.0

    @Published var integralError: Double = 0.0
    @Published var lastError: Double = 0.0
    @Published var lastUpdateTime: Date?

    var bag = Set<AnyCancellable>()


    func resetError() {
        integralError = 0.0
        lastError = 0.0
        lastUpdateTime = .now
    }

    func output(_ error: Double) -> Double {
        // Timing
        let currentTime = Date()
        let deltaTime: Double
        if let lastTime = lastUpdateTime {
            deltaTime = currentTime.timeIntervalSince(lastTime)
        } else {
            deltaTime = 0.0
        }
        lastUpdateTime = currentTime

        pOutput = error
        iOutput += error * deltaTime
        dOutput = deltaTime > 0 ? (error - lastError) / deltaTime : 0.0

        let output = 
        (pIsOn ? pConstant * pOutput : 0.0) + 
        (iIsOn ? iConstant * iOutput : 0.0) +
        (dIsOn ? dConstant * dOutput : 0.0)

        return output
    }
}
