import Foundation
import Combine
import SceneKit

class AppState: ObservableObject {

    @Published var virtualRobitBrain: RobitBrain!
    @Published var sceneKitInteractor: SceneKitService

    // Service
    let centralService = CentralService(serviceID: TransferService.phoneServiceUUID, charID: TransferService.phoneCharUUID)

    var bag = Set<AnyCancellable>()

    init() {
        let brain = RobitBrain()
        self.virtualRobitBrain = brain
        self.sceneKitInteractor = SceneKitService(mapController: brain.mapController)
        setUpSubscriptions()
    }

    private func setUpSubscriptions() {

        // Connect to Phone
        centralService.centralState.sink { [weak self] state in
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
                self?.centralService.retrievePeripheral()
            @unknown default:
                print("unkown")
            }
        }.store(in: &bag)

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

            }.assign(to: &sceneKitInteractor.$realRobitState)

        // RobitBrain to VirtualBody
        virtualRobitBrain
            .$motorSpeed
            .assign(to: &sceneKitInteractor.virtualRobitBody.$motorSpeed)

        // VirtualBody to RobitBrain
        sceneKitInteractor
            .virtualRobitBody
            .$state
            .subscribe(on: RunLoop.main)
            .receive(on: RunLoop.main)
            .assign(to: &virtualRobitBrain.$state)


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

        sceneKitInteractor
            .eventSubject
            .sink { [weak self] event in
                switch event {
                case .touchPoint(x: let x, z: let z):
                    let valueX = x + (x > 0 ? 0.5 : -0.5)
                    let valueZ = z + (z > 0 ? 0.5 : -0.5)
                    self?.virtualRobitBrain.mapController.setTile(value: 4, x: Int( valueX), z: Int(valueZ))
                }
            }.store(in: &bag)
    }
}
