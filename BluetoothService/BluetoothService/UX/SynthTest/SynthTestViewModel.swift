import Foundation
import Combine

class SynthTestViewModel: ObservableObject {
    var bag = Set<AnyCancellable>()

    let timer = Timer.publish(every: 0.1, on: .main, in: .default)
        .autoconnect()

    let upSwell = 0.1
    let downSwell = 0.1

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

        timer.sink { [weak self] _ in
            guard let self else {
                return
            }
            if finger0 > 0.0 {
                self.volume = min(self.volume + upSwell, 1)
                return
            }
            self.volume = max(self.volume - downSwell, 0)
        }.store(in: &bag)
    }

    func waveForm(_ input: Double) -> Double {
        return sin(2.0 * Double.pi * (currentPitch?.frequencyExact ?? 0.0) * input)*volume
    }

    var currentPitch: PitchInfo?  {
        Note.pitchInfo(inputLowerBound: -1.6, inputUpperBound: 1.6, outputLowerBound: 40, outputUpperBound: 81, inputValue: rotation)
    }
}
