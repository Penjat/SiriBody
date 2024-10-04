import Foundation
import Combine

enum ConnectionMode {
    case bluetooth(service: CentralService)
}

class MovementInteractor: ObservableObject {
    @Published var motorSpeed = (motor1Speed: 0, motor2Speed: 0)
    var bag = Set<AnyCancellable>()

    init(mode: ConnectionMode) {
        switch mode {
        case .bluetooth(service: let bluetoothService):
            $motorSpeed.sink { (motor1Speed, motor2Speed) in
                //Only write code here
                let motor1Byte = UInt8(((motor1Speed)) + 100)
                let motor2Byte = UInt8(((motor2Speed)) + 100)
                bluetoothService
                    .outputSubject
                    .send(
                        Data(
                            [UInt8(253),
                             UInt8(motor1Byte),
                             UInt8(motor2Byte),
                             UInt8(252)
                            ]))
            }.store(in: &bag)
        }
    }
}
