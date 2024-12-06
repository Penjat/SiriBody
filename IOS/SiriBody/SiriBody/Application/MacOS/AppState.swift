import Foundation
import Combine
import SceneKit

class AppState: ObservableObject {

    @Published var virtualRobitBrain: RobitBrain!
    @Published var sceneKitService: SceneKitService

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
}
