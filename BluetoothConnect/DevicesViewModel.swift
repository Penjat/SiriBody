import SwiftUI
import CoreBluetooth
import Combine

final class DevicesViewModel: ObservableObject {
    var dataSubject = PassthroughSubject<Data, Never>()
    
    @Published var state: CBManagerState = .unknown
    @Published var peripherals: [CBPeripheral] = []
    
    @Published var motor1Speed = 0
    @Published var motor2Speed = 0
    
    private lazy var manager: BluetoothManager = BluetoothManager()
    private lazy var bag: Set<AnyCancellable> = .init()
    
    
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
        
            .store(in: &bag)
        manager.peripheralSubject
            .filter { [weak self] in self?.peripherals.contains($0) == false }
            .sink { [weak self] in
                self?.peripherals.append($0)
                if $0.name == "SiriBody" {
                    print("SiriBody Found!!!!!!!!")
                    self?.manager.connect($0)
                }
            }
            .store(in: &bag)
        manager.start()
        dataSubject.throttle(for: 0.2, scheduler: DispatchQueue.main, latest: true)
            .sink { data in
            self.manager.sendData(data)
        }.store(in: &bag)
        
        $motor1Speed.sink { _ in
            self.sendPacket()
        }.store(in: &bag)
        
        $motor2Speed.sink { _ in
            self.sendPacket()
        }.store(in: &bag)
    }
    
    func sendPacket() {
        let data = Data([235, UInt8(min(255,motor1Speed)), UInt8(min(255,motor2Speed))])
        dataSubject.send(data)
    }
}

enum Motor {
    case motor1
    case motor2
}
