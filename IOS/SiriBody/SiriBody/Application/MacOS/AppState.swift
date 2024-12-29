import Foundation
import Combine
import SceneKit

class AppState: ObservableObject {
    
    @Published var virtualRobitBrain: RobitBrain!
    @Published var sceneKitService: SceneKitService
    
    @Published var rotationResponseMap: PIDResponseMap?
    
    // Service
    let centralService = CentralService(serviceID: TransferService.phoneServiceUUID, charID: TransferService.phoneCharUUID)
    
    var bag = Set<AnyCancellable>()
    
    init() {
        let brain = RobitBrain()
        self.virtualRobitBrain = brain
        self.sceneKitService = SceneKitService(robitBrain: brain)
        setUpSubscriptions()
    }
    
    private func setUpSubscriptions() {
        
        // Phone Input to Real RobitState
        centralService
            .inputSubject
            .throttle(for: .seconds(0.1), scheduler: RunLoop.main, latest: true)
            .compactMap { data -> RobitState? in
                guard let state = StateData.createFrom(data: data) else {
                    return nil
                }
                switch state {
                case .positionOrientation(devicePosition: let position, deviceOrientation: let orientation):
                    return RobitState(position: position, orientation: orientation)
                }
                
            }.assign(to: &sceneKitService.$realRobitState)
        
        sceneKitService
            .$realRobitState
            .combineLatest($rotationResponseMap)
            .compactMap { state, responseMap -> PIDResponseMap? in
                guard let responseMap else {
                    return nil
                }
                if let startTime = responseMap.dataPoints.first?.y,  startTime + PIDResponseMap.recordDuration < Date().timeIntervalSince1970  {
                    return nil
                } else {
                    return responseMap.plus(DataPoint(x: Double(state.orientation.z), y: Date().timeIntervalSince1970))
                }
            }
            .print()
            .assign(to: &$rotationResponseMap)
        
        
        // Highlight visited tiles
        //        virtualRobitBrain
        //            .mapController
        //            .$robitGridPosition
        //            .compactMap{ $0 }
        //            .sink { [weak self] gridPosition in
        //            guard let self else {
        //                return
        //            }
        //                let offset = virtualRobitBrain.mapController.grid.halfSize
        //                for x in 0..<3 {
        //                    for z in 0..<3 {
        //                        self.sceneKitInteractor.mapDisplayService.updateTile(x: gridPosition.x + x + offset - 1, z: gridPosition.z + offset + z - 1, color: NSColor.purple)
        //                    }
        //                }
        //            }.store(in: &bag)
    }
    
    func savePIDResponse() {
        guard let pidMap = rotationResponseMap else {
            print("no response to print")
            return
        }
        
        let homeURL = FileManager.default.homeDirectoryForCurrentUser
        let fileManager = FileManager.default
        if let documentsURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first {
            let fileURL = documentsURL.appendingPathComponent("pidMapData.json")
            
            do {
                try pidMap.saveToJSONFile(at: fileURL)
                print("Successfully saved JSON to \(fileURL.path)")
            } catch {
                print("Failed to save JSON:", error)
            }
        }
    }
}
