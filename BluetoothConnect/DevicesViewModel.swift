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
    
    @Published var turnTime = 0.2
//    deinit {
//        cancellables.cancel()
//    }
    let commands = [RobotMotion(speed: (motor1Speed: 60, motor2Speed: -60), time: 0.2),
                    RobotMotion(speed: (motor1Speed: 0, motor2Speed: 0), time: 2.0),
                    RobotMotion(speed: (motor1Speed: -60, motor2Speed: 60), time: 0.2),
                    RobotMotion(speed: (motor1Speed: 0, motor2Speed: 0), time: 2.0)]
    
    private let commandQueue =
      DispatchQueue(
        label: "robot.motion")
    
    var inMotion = false
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
        DispatchQueue.main.asyncAfter(deadline: .now() + turnTime) {
            let data = Data([235, UInt8(min(255,self.convertedSpeed(0))), UInt8(min(255,self.convertedSpeed(0)))])
            self.dataSubject.send(data)
        }
        
        
    }
    
    public func makeSquare() {
        inMotion = true
        commandQueue.async {
            while self.inMotion {
                for command in self.commands {
                    if !self.inMotion {
                        return
                    }
                    print(command.speed)
                    let data = Data([235, UInt8(min(255,self.convertedSpeed(command.speed.motor1Speed))), UInt8(min(255,self.convertedSpeed(command.speed.motor2Speed)))])
                    self.dataSubject.send(data)
                    usleep(UInt32(command.time*1000000))
                }
            }
        }
    }
    
    public func stopMotion() {
        inMotion = false
        motorSpeed = (0,0)
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
