import AVFoundation
import Combine

class Synth: ObservableObject {
    @Published var wavCap = false
    @Published var isPlaying = false
    @Published var wav: (Double) -> Double = sin
    var bag = Set<AnyCancellable>()
    static var amplitude: Float = 1

    typealias Signal = (_ frequency: Float, _ time: Float) -> Float

    public var volume: Float {
        set {
            audioEngine.mainMixerNode.outputVolume = newValue
        }
        get {
            audioEngine.mainMixerNode.outputVolume
        }
    }

    public var frequencyRampValue: Float = 0

    public var frequency: Float = 440 {
        didSet {
            if oldValue != 0 {
                frequencyRampValue = frequency - oldValue
            } else {
                frequencyRampValue = 0
            }
        }
    }

    public func startPlaying() {
        volume = 0.05
    }

    public func stopPlaying() {
        volume = 0
    }

    func pressedKey(_ keyNumber: Int, down: Bool) {
        print("pressed \(keyNumber)")
        if down {
            let halfStepsFromA4 = (keyNumber - 69)
            let a = 1.059463094359
            frequency = Float(440.0 * pow(a, Double(halfStepsFromA4)))
            startPlaying()
            return
        }
        stopPlaying()
        frequency = 0
    }

    private var audioEngine: AVAudioEngine
    private lazy var sourceNode = AVAudioSourceNode { _, _, frameCount, audioBufferList in
        let ablPointer = UnsafeMutableAudioBufferListPointer(audioBufferList)

        let localRampValue = self.frequencyRampValue
        let localFrequency = self.frequency - localRampValue

        let period = 1 / localFrequency

        for frame in 0..<Int(frameCount) {
            let percentComplete = self.time / period
            let sampleVal = self.signal(localFrequency, self.time)
            self.time += self.deltaTime

            if self.wavCap {
                self.time = fmod(self.time, period)
            }

            for buffer in ablPointer {
                let buf: UnsafeMutableBufferPointer<Float> = UnsafeMutableBufferPointer(buffer)
                buf[frame] = sampleVal
            }
        }

        self.frequencyRampValue = 0

        return noErr
    }

    private var time: Float = 0
    private let sampleRate: Double
    private let deltaTime: Float
    private var signal: Signal = { frequency, time in
        let theta = Double(2.0 * Float.pi * frequency * time)
        return amplitude * Float(sin(theta))
    }

    // MARK: Init



    init() {
        audioEngine = AVAudioEngine()

        let mainMixer = audioEngine.mainMixerNode
        let outputNode = audioEngine.outputNode
        let format = outputNode.inputFormat(forBus: 0)

        sampleRate = format.sampleRate
        deltaTime = 1 / Float(sampleRate)

        let inputFormat = AVAudioFormat(commonFormat: format.commonFormat,
                                        sampleRate: format.sampleRate,
                                        channels: 1,
                                        interleaved: format.isInterleaved)

        audioEngine.attach(sourceNode)
        audioEngine.connect(sourceNode, to: mainMixer, format: inputFormat)
        audioEngine.connect(mainMixer, to: outputNode, format: nil)
        mainMixer.outputVolume = 0

        do {
            try audioEngine.start()
        } catch {
            print("Could not start engine: \(error.localizedDescription)")
        }

        $wav.sink { wav in
            self.signal = { [weak self] frequency, time in
//                let theta = Double(2.0 * Float.pi * frequency * time)
                return Synth.amplitude * Float(self?.wav(Double(time)) ?? 0.0)/2
            }
        }.store(in: &bag)

    }

    // MARK: Public Functions

    public func setWaveformTo(_ signal: @escaping Signal) {
        self.signal = signal
    }

}

