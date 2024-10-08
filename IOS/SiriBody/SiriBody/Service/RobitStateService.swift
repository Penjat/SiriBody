import Foundation
import Combine

struct RobitState {
    let pitch: Double
    let roll: Double
    let yaw: Double
}

class RobitStateService: ObservableObject {
    @Published var state: RobitState?
    var bag = Set<AnyCancellable>()
    
    init(motionService: MotionService) {
        motionService.$position.sink { [weak self] position in
            
            self?.state = RobitState(
                pitch: position?.attitude.pitch ?? 0.0,
                roll: position?.attitude.roll ?? 0.0,
                yaw: position?.attitude.yaw ?? 0.0)
            
        }.store(in: &bag)
        
        motionService.startPositionUpdates()
    }
}
