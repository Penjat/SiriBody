import Foundation
import Combine
import SceneKit
import SwiftUI

class VirtualRobitBody: ObservableObject {

    @Published var motorSpeed = MotorOutput.zero
    @Published var speedFactor = 0.05
    @Published var turnFactor = 0.005
    @Published var maxVelocity = 20.0
    @Published var state = RobitState.zero

    public func updateRobit() {
        guard let robit = node else { return }
        let forwardBackward = Double(motorSpeed.motor1 + motorSpeed.motor2)*(-speedFactor)
        let leftRight = Double(motorSpeed.motor1 - motorSpeed.motor2) * turnFactor

        let forwardVelocity = SCNVector3(x: robit.worldForward.x*forwardBackward, y: robit.worldForward.y*forwardBackward, z: robit.worldForward.z*forwardBackward)
        robit.physicsBody?.velocity = forwardVelocity

        let angularVelocityY = Float(-leftRight)
        robit.physicsBody?.angularVelocity = SCNVector4(0, 1, 0, angularVelocityY)

        state = RobitState(position: robit.presentation.simdPosition, orientation: SIMD3(x: robit.presentation.simdEulerAngles.z, y: robit.presentation.simdEulerAngles.y, z: robit.presentation.simdEulerAngles.x) )
    }

    lazy var node: SCNNode? = {
        guard let scene = SCNScene(named: "SiriBodyVirtual.obj"), let modelNode = scene.rootNode.childNodes.first else {
            print("Error: Failed to load the scene")
            return nil
        }
        let parentNode = SCNNode()
        parentNode.eulerAngles = SCNVector3(0.0, 0.0, Double.pi/2)
        modelNode.scale = SCNVector3(0.01, 0.01, 0.01)
        modelNode.addChildNode(virtualRobitCam)
        modelNode.eulerAngles = SCNVector3(0.0, 0.0, -Double.pi/2)
        virtualRobitCam.position = SCNVector3(0, 150, -35)

        let boxGeometry = SCNBox(width: 1, height: 1, length: 1, chamferRadius: 0.0)
        let boxMaterial = SCNMaterial()
        boxMaterial.diffuse.contents = NSColor.gray
        boxGeometry.materials = [boxMaterial]

        let boxNode = SCNNode(geometry: boxGeometry)

        let robitShape = SCNPhysicsShape(geometry: boxGeometry)

        let physicsBody = SCNPhysicsBody(type: .dynamic, shape: robitShape)
        physicsBody.mass = 10.0
        parentNode.addChildNode(modelNode)
        parentNode.physicsBody = physicsBody

        return parentNode
    }()

    lazy var virtualRobitCam = {
        let cameraNode = SCNNode()
        cameraNode.eulerAngles = SCNVector3(0, Double.pi, 0)
        return cameraNode
    }()
}
