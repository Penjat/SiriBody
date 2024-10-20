import Foundation

struct RobitState {
    let devicePosition: SIMD3<Float>
    let deviceOrientation: SIMD3<Float>
    let linearVelocity: SIMD3<Float>?
    let gravity: SIMD4<Float>
}
