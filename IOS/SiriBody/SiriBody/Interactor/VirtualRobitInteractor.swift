import Foundation
import Combine
import SceneKit

class VirtualRobitInteractor: ObservableObject {
    @Published var motorSpeed = (motor1Speed: 0, motor2Speed: 0)
    @Published var virtualRobitPosition = RobitPosition(position: SIMD3<Float>(0, 0, 0), orientation: SIMD3<Float>(0, 0, 0))
    var bag = Set<AnyCancellable>()

    init() {
        $motorSpeed.sink { [weak self] speed in
            print("applying force")
            self?.virtualRobit?.physicsBody?.applyForce(SCNVector3(speed.motor1Speed, Int(0.0), speed.motor2Speed), asImpulse: false)
        }.store(in: &bag)
    }

    lazy var virtualRobit: SCNNode? = {
        guard let scene = SCNScene(named: "SiriBodyVirtual.obj"), let modelNode = scene.rootNode.childNodes.first else {
            print("Error: Failed to load the scene")
            return nil
        }
        modelNode.scale = SCNVector3(0.01, 0.01, 0.01)
        modelNode.addChildNode(virtualRobitCam)
        virtualRobitCam.position = SCNVector3(0, 150, -35)

        let boxGeometry = SCNBox(width: 5, height: 5, length: 5, chamferRadius: 0.0)
        let boxMaterial = SCNMaterial()
        boxMaterial.diffuse.contents = NSColor.gray
        boxGeometry.materials = [boxMaterial]

        let boxNode = SCNNode(geometry: boxGeometry)

        let robitShape = SCNPhysicsShape(geometry: boxGeometry)

        let physicsBody = SCNPhysicsBody(type: .dynamic, shape: robitShape)
        physicsBody.mass = 10.0
        modelNode.physicsBody = physicsBody

        return modelNode
    }()
    
    lazy var virtualRobitCam = {
        let cameraNode = SCNNode()
        cameraNode.eulerAngles = SCNVector3(0, Double.pi, 0)
        return cameraNode
    }()
}
