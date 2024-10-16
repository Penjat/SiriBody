import Foundation
import Combine

struct RobitPosition {
    let position: SIMD3<Float>
    let orientation: SIMD3<Float>
}

class RobitPositionService: ObservableObject {
    @Published var robitPosition = RobitPosition(position: SIMD3<Float>(0, 0, 0), orientation: SIMD3<Float>(0, 0, 0))
}
