import Foundation
import Combine

struct RobitState {
    let pitch: Double
    let roll: Double
    let yaw: Double
}

class RobitStateService: ObservableObject {
    @Published var state: RobitState?
    
}
