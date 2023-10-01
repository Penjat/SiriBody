import Foundation
import Combine

class SynthTestViewModel: ObservableObject {
    var bag = Set<AnyCancellable>()

    @Published var finger0 = 0.0
    @Published var finger1 = 0.0
    @Published var finger2 = 0.0

    @Published var pressedA = false
    @Published var pressedB = false
    @Published var pressedC = false

    @Published var pitch = 0.0
    @Published var roll = 0.0
    @Published var yaw = 0.0

    init(synth: Synth) {

    }
}
