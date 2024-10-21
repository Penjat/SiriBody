import Foundation

struct RobitState {
    let position: SIMD3<Float>
    let orientation: SIMD3<Float>
    let linearVelocity: SIMD3<Float>?
    let gravity: SIMD4<Float>?

    init(position: SIMD3<Float>, orientation: SIMD3<Float>, linearVelocity: SIMD3<Float>? = nil, gravity: SIMD4<Float>? = nil) {
        self.position = position
        self.orientation = orientation
        self.linearVelocity = linearVelocity
        self.gravity = gravity
    }

    static var zero: RobitState {
        RobitState(position: SIMD3<Float>.zero,
                   orientation: SIMD3<Float>.zero)
    }
}
