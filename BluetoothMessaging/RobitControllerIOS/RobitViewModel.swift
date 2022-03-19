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
                
                self.motionService.goal.send(0.0)
            case .faceSouth:
                self.reciededData.append("face south")
                
                self.motionService.goal.send(Double.pi/2)
            case .faceWest:
                self.motionService.goal.send(Double.pi/4)
            case .faceEast:
                self.motionService.goal.send(Double.pi/(-4))
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
            switch motionState {
                
            case .turningLeft:
                print("turning left")
                let data = Data([235, UInt8(min(255,160)), UInt8(min(255,60))])
                self.centralService.commandSubject.send(data)
            case .stopped:
                print("stopped")
                let data = Data([235, UInt8(min(255,0)), UInt8(min(255,0))])
                self.centralService.commandSubject.send(data)
            }
        }.store(in: &bag)
        
        peripheralService.start()
    }
}
