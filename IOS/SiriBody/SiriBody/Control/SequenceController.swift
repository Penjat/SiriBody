import Foundation

enum SequenceStep {
    case wait(TimeInterval)
    case reapeatSequence
    case runCommand(Command)
}

class SequenceController: ObservableObject {
    @Published var sequence = [SequenceStep]()
    @Published var stepNumber = 0

    var nextStep: SequenceStep? {
        stepNumber += 1
        if stepNumber < sequence.count {
            return sequence[stepNumber]
        }
        stepNumber = 0
        return nil
    }
}
