import Foundation
import Combine
import SceneKit

class VirtualRobitInteractor: ObservableObject {
    @Published var motorSpeed = (motor1Speed: 0, motor2Speed: 0)
    @Published var virtualRobitPosition = RobitPosition(position: SIMD3<Float>(0, 0, 0), orientation: SIMD3<Float>(0, 0, 0))
    
    lazy var virtualRobit: SCNNode? = {
        guard let scene = SCNScene(named: "SiriBodyVirtual.obj"), let modelNode = scene.rootNode.childNodes.first else {
            print("Error: Failed to load the scene")
            return nil
        }
        modelNode.scale = SCNVector3(0.01, 0.01, 0.01)
        modelNode.addChildNode(virtualRobitCam)
        virtualRobitCam.position = SCNVector3(0, 150, -35)
        return modelNode
    }()
    
    lazy var virtualRobitCam = {
        let cameraNode = SCNNode()
        cameraNode.eulerAngles = SCNVector3(0, Double.pi, 0)
        return cameraNode
    }()
}
