import Combine
import RealityKit

class RealityKitService: ObservableObject {
    private var arView: ARView?

    @Published var devicePosition = SIMD3<Float>(0.0, 0.0, 0.0)
    @Published var deviceOrientation = SIMD3<Float>(0.0, 0.0, 0.0)

    func setARView(_ view: ARView) {
        self.arView = view
        self.arView?.environment.background = .color(.gray)
    }
}
