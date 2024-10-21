import Foundation
import Combine


enum ConnectionMode {
    case bluetooth(service: CentralService)
    case sceneKit
}

class MovementInteractor: ObservableObject {
    @Published var motorSpeed = (motor1Speed: 0, motor2Speed: 0)
    var bag = Set<AnyCancellable>()

    init(mode: ConnectionMode) {
        switch mode {
        case .bluetooth(service: let bluetoothService):
            $motorSpeed.sink { (motor1Speed, motor2Speed) in
                let motorDirectionByte = UInt8((motor1Speed > 0 ? 1 : 0) + (motor2Speed > 0 ? 2 : 0))
                let motor1Byte = UInt8(abs(motor1Speed))
                let motor2Byte = UInt8(abs(motor2Speed))
                bluetoothService
                    .outputSubject
                    .send(
                        Data(
                            [UInt8(253),
                             motorDirectionByte,
                             motor1Byte,
                             motor2Byte,
                             UInt8(252)
                            ]))
            }.store(in: &bag)
        case .sceneKit:
            break
        }
    }
}
