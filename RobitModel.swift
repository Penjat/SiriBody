import Foundation
import Combine

class RobitModel: ObservableObject {

    enum Constants {
        static var accelerationRange = -1.0...1.0

    }

    @Published var acceleration = 0.005
    @Published var maxVelocity = 1.0
    @Published var rotation = 0.0
    @Published var velocity = 0.0
    @Published var throttleAmt = 0.0
    @Published var friction = 0.9

    var lastTime = Date()

    private var timerPublisher: AnyPublisher<Date, Never>!
    public var statePublisher = PassthroughSubject<RobitState, Never>()
    var bag = Set<AnyCancellable>()

    init() {

        timerPublisher = Timer.publish(every: 0.1, on: .main, in: .common)
            .autoconnect()
            .eraseToAnyPublisher()


        timerPublisher
            .sink { [weak self] currentTime in
                guard let self else {
                    return
                }
                let deltaTime = currentTime.timeIntervalSince(self.lastTime)*100
                velocity = max(-self.maxVelocity, min(self.maxVelocity, velocity + acceleration*throttleAmt*deltaTime))
                velocity *= friction
                rotation += velocity*deltaTime
                self.lastTime = currentTime
                statePublisher.send(RobitState(rotation: rotation, deltaTime: deltaTime))
//                print("rotation: \(rotation)  velocity: \(velocity)")
            }.store(in: &bag)
    }

    public func setThrottle(_ throttle: Double) {
        self.throttleAmt = max(-1.0, min(1.0, throttle))
    }

    struct RobitState {
        let rotation: Double
        let deltaTime: Double
    }
}
