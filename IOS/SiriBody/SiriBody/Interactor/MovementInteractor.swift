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
                bluetoothService.
            }.store(in: &bag)
        }
        
    }
}
