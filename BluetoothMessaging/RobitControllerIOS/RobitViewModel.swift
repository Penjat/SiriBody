import Foundation
import Combine

class RobitViewModel: ObservableObject {
    let peripheralService = PeripheralService()
    let centralService = CentralService(serviceID: TransferService.siriBodyServiceUUID, charID: TransferService.siriBodyCharUUID)
    let motionService = MotionService()
    
    @Published var messageText = ""
    @Published var reciededData = [String]()
    
    var bag = Set<AnyCancellable>()
    
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
                self.motionService.goal.send(.driveFor(time: Date.timeIntervalSinceReferenceDate+2.0 ))
                self.reciededData.append("move forward")
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
            self.centralService.commandSubject.send(data)
            
            
        }.store(in: &bag)
        
        peripheralService.start()
    }
}
