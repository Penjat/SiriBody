import Combine
import RealityKit

class RealityKitService: ObservableObject {
    private var arView: ARView?
    
    func setARView(_ view: ARView) {
        self.arView = view
        self.arView?.environment.background = .color(.gray)
    }
}
