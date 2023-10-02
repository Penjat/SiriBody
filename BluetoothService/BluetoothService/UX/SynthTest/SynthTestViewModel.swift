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

    @Published var rotation = 0.0

    var volume = 0.0

    @Published var isPressed = false
    @Published var frequency = 440.0

    init(synth: Synth, motionService: MotionService) {
        synth.wav = waveForm(_:)
        synth.startPlaying()
        $isPressed
            .removeDuplicates()
            .sink { [weak self] isPressed in
                if isPressed {
                    self?.frequency = Double.random(in: 60.0..<880.0)
                }
        }.store(in: &bag)

        motionService.positionPublisher.sink { [weak self] positionData in

            self?.rotation = atan2(positionData.gravity.x, -positionData.gravity.y)
        }.store(in: &bag)
    }

    func waveForm(_ input: Double) -> Double {
        return sin(2.0 * Double.pi * frequency * input)*volume
    }
}
