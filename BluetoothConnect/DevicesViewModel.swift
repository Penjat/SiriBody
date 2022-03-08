import SwiftUI
import CoreBluetooth
import Combine

final class DevicesViewModel: ObservableObject {
    var dataSubject = PassthroughSubject<Data, Never>()
    
    @Published var state: CBManagerState = .unknown
    @Published var peripherals: [CBPeripheral] = []
    
    @Published var motorSpeed = (motor1Speed: 0, motor2Speed: 0)
    
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
                    print("SiriBody Found!!!!!!!! \($0)")
                    
                    self?.manager.connect($0)
                }
                print($0)
            }
            .store(in: &bag)
        manager.start()
        dataSubject.throttle(for: 0.2, scheduler: DispatchQueue.main, latest: true)
            .sink { data in
            self.manager.sendData(data)
        }.store(in: &bag)
        
        $motorSpeed.sink { _ in
            self.sendPacket()
        }.store(in: &bag)
    }
    
    public func convertedSpeed(_ speed: Int) -> Int {
        Int(speed < 0 ? abs(speed) : speed + 100)
    }
    
    public func turn90Degrees() {
        let data = Data([235, UInt8(min(255,convertedSpeed(60))), UInt8(min(255,convertedSpeed(-60)))])
        dataSubject.send(data)
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            let data = Data([235, UInt8(min(255,self.convertedSpeed(0))), UInt8(min(255,self.convertedSpeed(0)))])
            self.dataSubject.send(data)
        }
    }
    
    private func sendPacket() {
        let data = Data([235, UInt8(min(255,motorSpeed.motor1Speed)), UInt8(min(255,motorSpeed.motor2Speed))])
        dataSubject.send(data)
    }
}

enum Motor {
    case motor1
    case motor2
}
