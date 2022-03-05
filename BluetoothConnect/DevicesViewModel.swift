import SwiftUI
import CoreBluetooth
import Combine

final class DevicesViewModel: ObservableObject {
    
    @Published var state: CBManagerState = .unknown
    @Published var peripherals: [CBPeripheral] = []
    
    @Published var motor1Speed = 0.0
    @Published var motor2Speed = 0.0
    
    private lazy var manager: BluetoothManager = BluetoothManager()
    private lazy var cancellables: Set<AnyCancellable> = .init()
    
    
//    deinit {
//        cancellables.cancel()
//    }
    
    func start() {
        manager.stateSubject
            .sink { [weak self] state in
                self?.state = state
                switch state {
                case .unknown:
                    print("unkown")
                case .resetting:
                    print("restting")
                case .unsupported:
                    print("unsupported")
                case .unauthorized:
                    print("unauthourised")
                case .poweredOff:
                    print("power off")
                case .poweredOn:
                    print("power on")
                    self?.manager.startScanning()
                }
            }
        
            .store(in: &cancellables)
        manager.peripheralSubject
            .filter { [weak self] in self?.peripherals.contains($0) == false }
            .sink { [weak self] in
                self?.peripherals.append($0)
                if $0.name == "SiriBody" {
                    print("SiriBody Found!!!!!!!!")
                    self?.manager.connect($0)
                }
            }
            .store(in: &cancellables)
        manager.start()
    }
    
    func sendMessage(_ message: String) {
        manager.writeOutgoingValue(data: message)
    }
}
