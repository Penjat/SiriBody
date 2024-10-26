import Foundation

enum SequenceStep {
    case wait(TimeInterval)
    case reapeatSequence
    case runCommand(Command)
}

class SequenceController: ObservableObject {
    @Published var sequence = [SequenceStep]()
    @Published var stepNumber = 0

    @Published var motionCommand: Command?


    func stepComplete() {
        stepNumber += 1
        if stepNumber < sequence.count {
            switch sequence[stepNumber] {
            case .reapeatSequence:
                break
            case.runCommand(let command):
                motionCommand = command
            case .wait(let seconds):
                break
            }
        }

        stepNumber = 0
        motionCommand = nil
    }
}
