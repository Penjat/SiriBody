import Foundation
import Combine

class PIDController: ObservableObject {
    @Published var goal = 0.0
    @Published var pValue = 3.0
    @Published var iValue = 0.0001
    @Published var dValue = 2.0

    @Published var pIsOn = true
    @Published var iIsOn = true
    @Published var dIsOn = true

    var accumulatedError = 0.0
    var lastError = 0.0

    func processInput(_ input: PIDController.ContollerInput) -> Double {
        let error = (goal - input.rotation)/360.0
        let changeInError = (error - lastError)/input.deltaTime
        let pAmt = pIsOn ? (error * pValue) : 0
        let iAmt = iIsOn ? (accumulatedError * iValue) : 0
        let dAmt = dIsOn ? (changeInError*dValue) : 0
        accumulatedError += error*input.deltaTime
        lastError = error
        let throttle = pAmt + iAmt + dAmt
        return throttle
    }

    struct ContollerInput {
        let rotation: Double

        // Seems like these would be usefull to include
        // but they don't seem nesseccary yet
        let deltaTime: Double
//        let velocity: Double

    }
}
