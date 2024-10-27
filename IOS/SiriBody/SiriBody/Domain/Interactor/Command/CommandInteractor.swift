import Foundation

enum SequenceStep {
    case wait(TimeInterval)
    case reapeatSequence
    case runCommand(Command)
}

class CommandInteractor: ObservableObject {
    @Published var sequence = [SequenceStep]()
    @Published var stepNumber = 0
    @Published var motionCommand: Command?

    func stepComplete() {
        stepNumber += 1
        if stepNumber < sequence.count {
            runStep()
            return
        }

        stepNumber = 0
        motionCommand = nil
    }

    func startSquareSequence() {
        stepNumber = 0
        sequence = [
            .runCommand(.moveTo(x: 10, z: 10)),
            .runCommand(.moveTo(x: -10, z: 10)),
            .runCommand(.moveTo(x: -10, z: -10)),
            .runCommand(.moveTo(x: 10, z: -10)),
            .reapeatSequence
        ]
        runStep()
    }

    func startLineSequence() {
        stepNumber = 0
        sequence = [
            .runCommand(.moveTo(x: 10, z: 0)),
            .runCommand(.moveTo(x: -10, z: 0)),
            .reapeatSequence
        ]
        runStep()
    }

    func runStep() {
        process(sequenceStep: sequence[stepNumber])
    }

    func process(sequenceStep: SequenceStep) {
        switch sequenceStep {
        case .reapeatSequence:
            stepNumber = 0
            process(sequenceStep: sequence[stepNumber])
            return
        case.runCommand(let command):
            motionCommand = command
            return
        case .wait(_):
            return
        }
    }
}
