import Foundation
import Combine

class RobitViewModel: ObservableObject {
    let peripheralService = PeripheralService()
    let centralService = CentralService(serviceID: TransferService.siriBodyServiceUUID, charID: TransferService.siriBodyCharUUID)
    let motionService = MotionService()
    
    @Published var messageText = ""
    @Published var reciededData = [String]()
    
    var bag = Set<AnyCancellable>()
    var speed = 100
    
    init() {
        peripheralService.dataIN.receive(on: DispatchQueue.main, options: nil).sink { cmd in
            switch cmd {
            case .unknown:
                self.reciededData.append("unknown")
            case .faceNorth:
                self.reciededData.append("face north")
                
                self.motionService.goal.send(.turnTo(angle: 0.0))
            case .faceSouth:
                self.reciededData.append("face south")
                
                self.motionService.goal.send(.turnTo(angle: Double.pi))
            case .faceWest:
                self.motionService.goal.send(.turnTo(angle:Double.pi/(2)))
                self.reciededData.append("face west")
            case .faceEast:
                self.motionService.goal.send(.turnTo(angle: Double.pi/(-2)))
                self.reciededData.append("face east")
            case .moveForward:
                self.motionService.goal.send(.driveFor(time: Date.timeIntervalSinceReferenceDate+1.0, leftSpeed: Double(self.speed), rightSpeed: Double(self.speed)))
                self.reciededData.append("move forward")
            case .justLeft:
                self.motionService.goal.send(.driveTo(angle: Double.pi/4, leftSpeed: Double(self.speed), rightSpeed: 0))
                self.reciededData.append("just left")
            case .justRight:
                self.motionService.goal.send(.driveTo(angle: Double.pi/4, leftSpeed: 0, rightSpeed: Double(self.speed)))
                self.reciededData.append("just right")
            case .speed10:
                self.speed = 10
            case .speed20:
                self.speed = 20
            case .speed30:
                self.speed = 30
            case .speed40:
                self.speed = 40
            case .speed50:
                self.speed = 50
            case .speed60:
                self.speed = 60
            case .speed70:
                self.speed = 70
            case .speed80:
                self.speed = 80
            case .speed90:
                self.speed = 90
            case .speed100:
                self.speed = 100
            }
            
        }.store(in: &bag)
        
        peripheralService.peripheralState.sink { state in
            switch state {
            case .unknown:
                print("unknown")
            case .resetting:
                print("resetting")
            case .unsupported:
                print("unsupported")
            case .unauthorized:
                print("unauthorized")
            case .poweredOff:
                print("powered off")
            case .poweredOn:
                print("powered on")
                self.peripheralService.setupPeripheral()
                self.peripheralService.startAdvertising()
            }
        }.store(in: &bag)
        
        centralService.centralState.sink { state in
            switch state {
                
            case .unknown:
                print("Unkown")
            case .resetting:
                print("resetting")
            case .unsupported:
                print("unsupported")
            case .unauthorized:
                print("unauthorized")
            case .poweredOff:
                print("poweredOff")
            case .poweredOn:
                print("poweredOn")
                self.centralService.retrievePeripheral()
            @unknown default:
                print("unkown")
            }
        }.store(in: &bag)
        
        motionService.motionStatePublisher.sink { motionState in
            
            let speed1 = UInt8(motionState.leftSpeed*7/100 + 7)
            let speed2 = UInt8(motionState.rightSpeed*7/100 + 7)
            
            let data = Data([speed1 + (speed2 << 4)])
            let asString = data.map { String(format: "%02x", $0) }.joined()
            print("\(speed1) \(speed2) asData: \(asString)")
            self.centralService.commandSubject.send(data)
            
            
        }.store(in: &bag)
        
        peripheralService.start()
    }
}
