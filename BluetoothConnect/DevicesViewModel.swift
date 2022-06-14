import SwiftUI
import CoreBluetooth
import Combine

final class DevicesViewModel: ObservableObject {
    private var txCharacteristic: CBCharacteristic!
    private var rxCharacteristic: CBCharacteristic!
    var dataSubject = PassthroughSubject<Data, Never>()
    
    @Published var state: CBManagerState = .unknown
    @Published var peripherals: [CBPeripheral] = []
    
    @Published var motorSpeed = (motor1Speed: 0, motor2Speed: 0)
    
    lazy var manager: BluetoothManager = BluetoothManager()
    private lazy var bag: Set<AnyCancellable> = .init()
    @Published var connectedBody: CBPeripheral?
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
        
        $motorSpeed.throttle(for: 0.1, scheduler: DispatchQueue.main, latest: true).sink { newSpeed in
            self.sendPacket(speed1: newSpeed.motor1Speed, speed2: newSpeed.motor2Speed)
        }.store(in: &bag)
        
//        dataSubject
//            .sink { data in
//            self.sendData(data)
//        }.store(in: &bag)
        
        manager.eventSubject.sink(receiveValue: { event in
            switch event {
            case .DidUpdateState(state: let state):
                self.processUpdateState(state: state)
            case .DidDiscover(central: _, peripheral: let peripheral):
                if peripheral.name == "SiriBody" {
                    print("SiriBody Found!!!!!!!! \(peripheral)")
                    self.peripherals.append(peripheral)
                    self.manager.connect(peripheral)
                }
            case .DidConnect(central: _, peripheral: let peripheral):
                self.connectedBody = peripheral
                self.connectedBody?.discoverServices(nil)
            case .DidDiscoverService(peripheral: let peripheral, error: let error):
                if ((error) != nil) {
                    print("Error discovering services: \(error!.localizedDescription)")
                    return
                }
                guard let services = peripheral.services else {
                    return
                }
                //We need to discover the all characteristic
                for service in services {
                    peripheral.discoverCharacteristics(nil, for: service)
                }
                print("Discovered Services: \(services)")
            case .DidDiscoverCharacteristic(peripheral: _, service: let service, error: let error):
                guard let characteristics = service.characteristics else {
                    return
                }
                for characteristic in characteristics {
                    print("\(characteristic)")
                    self.txCharacteristic = characteristic
                    print("TX Characteristic: \(self.txCharacteristic.uuid)")
                }
                
            case .DidDisconnect(central: let central, peripheral: let peripheral, error: let error):
                self.connectedBody = nil
            }
            print(event)
        }).store(in: &bag)
        
        manager.start()
    }
    
    func processUpdateState(state: CBManagerState) {
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
            self.manager.startScanning()
        }
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
        sendData(data)
    }
    
    func sendData(_ data: Data) {
        if let bluefruitPeripheral = connectedBody {
            if let txCharacteristic = txCharacteristic {
                bluefruitPeripheral.writeValue(data, for: txCharacteristic, type: CBCharacteristicWriteType.withoutResponse)
            }
        }
    }
}

enum Motor {
    case motor1
    case motor2
}
