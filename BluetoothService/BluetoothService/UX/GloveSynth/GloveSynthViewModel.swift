import Foundation
import Combine
import SwiftUI

class GloveSynthViewModel: ObservableObject {

    let volumeMax = 0.0
    let upSwell = 0.1
    let downSwell = 0.1

    let timer = Timer.publish(every: 0.1, on: .main, in: .default)
        .autoconnect()

    @Published var isPressed = false
    @Published var frequency = 440.0
    @Published var gloveState: PowerGloveDataObject?


    var volume = 0.0

    var bag = Set<AnyCancellable>()

    init(synth: Synth, gloveService: GloveDataService) {
        synth.frequency = 440.0
        synth.startPlaying()
        synth.wav = waveForm(_:)
        $isPressed
            .removeDuplicates()
            .sink { [weak self] isPressed in
                if isPressed {
                    self?.frequency = Double.random(in: 60.0..<880.0)
                }

        }.store(in: &bag)

        timer.sink { [weak self] _ in
            guard let self else {
                return
            }
            if isPressed {
                self.volume = min(self.volume + upSwell, 1)
                return
            }
            self.volume = max(self.volume - downSwell, 0)
        }.store(in: &bag)

        gloveService.$gloveState.assign(to: &$gloveState)

        $gloveState.sink { [weak self] gloveData in
            self?.isPressed = gloveData?.fingerSensor1 ?? 0 < 150
        }.store(in: &bag)
    }

    func waveForm(_ input: Double) -> Double {
        return triangleWave(2.0 * Double.pi * frequency * input)*volume
    }
}
