import SwiftUI
import CoreBluetooth
import Combine

final class DevicesViewModel: ObservableObject {
    var dataSubject = PassthroughSubject<Data, Never>()
    
    @Published var state: CBManagerState = .unknown
    @Published var peripherals: [CBPeripheral] = []
    
    @Published var motorSpeed = (motor1Speed: 0, motor2Speed: 0)
    
    lazy var manager: BluetoothManager = BluetoothManager()
    private lazy var bag: Set<AnyCancellable> = .init()
    
    @Published var turnTime = 0.2
    
    let commands = [RobotMotion(speed: (motor1Speed: -60, motor2Speed: 60), time: 0.257*2),
                    RobotMotion(speed: (motor1Speed: 0, motor2Speed: 0), time: 2.0),
                    RobotMotion(speed: (motor1Speed: -60, motor2Speed: -60), time: 2.0),
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
        
        $motorSpeed.throttle(for: 0.1, scheduler: DispatchQueue.main, latest: true).sink { newSpeed in
            self.sendPacket(speed1: newSpeed.motor1Speed, speed2: newSpeed.motor2Speed)
        }.store(in: &bag)
        
        dataSubject
            .sink { data in
            self.manager.sendData(data)
        }.store(in: &bag)
    }
    
    public func convertedSpeed(_ speed: Int) -> Int {
        guard speed != 0 else {
            return 0
        }
        return speed < 0 ? abs(speed) : speed + 100
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
                    print(command.speed)
                    let speed1 = UInt8(command.speed.motor1Speed*7/100 + 7)
                    let speed2 = UInt8(command.speed.motor2Speed*7/100 + 7)
                    
                    let data = Data([speed1 + (speed2 << 4)])
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
    
    private func sendPacket(speed1: Int, speed2: Int) {
        let s1 = (speed1*7)/100 + 7
        let s2 = ((speed2*7)/100 + 7) << 4
        let data = Data([UInt8(min(s1 + s2, 256))])
        manager.sendData(data)
    }
}

enum Motor {
    case motor1
    case motor2
}
