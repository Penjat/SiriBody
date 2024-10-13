import SwiftUI
import SceneKit

struct SceneKitView: NSViewRepresentable {
    func makeNSView(context: Context) -> SCNView {
        // Create the SCNView
        let scnView = SCNView(frame: .zero)
        
        
        // Set up the scene
        let scene = SCNScene()
        scnView.scene = scene
        scene.physicsWorld.gravity = SCNVector3(0, -9.8, 0)
        
        // Configure the view
        scnView.allowsCameraControl = true
        scnView.backgroundColor = NSColor.black
        
        // Add content to the scene
        let boxNode = createBox()
        
        scene.rootNode.addChildNode(boxNode)
        boxNode.position = SCNVector3(-5, 3, -2)
        
        let lightNode = createLight()
        scene.rootNode.addChildNode(lightNode)
        
        let floorNode = createFloor()
        scene.rootNode.addChildNode(floorNode)
        
        return scnView
    }
    
    func updateNSView(_ nsView: SCNView, context: Context) {
        // Update the view if needed
    }
    
    // Helper function to create a box node
    private func createBox() -> SCNNode {
        let boxGeometry = SCNBox(width: 0.5, height: 0.5, length: 0.5, chamferRadius: 0.1)
        let boxMaterial = SCNMaterial()
        boxMaterial.diffuse.contents = NSColor.blue
        boxGeometry.materials = [boxMaterial]
        
        
        let boxNode = SCNNode(geometry: boxGeometry)
        let physicsBody = SCNPhysicsBody(type: .dynamic, shape: nil)
        physicsBody.mass = 1.0
        boxNode.physicsBody = physicsBody
        
        return boxNode
    }
    
    private func createFloor() -> SCNNode {
        let boxGeometry = SCNBox(width: 20, height: 0.1, length: 20, chamferRadius: 0.0)
        let boxMaterial = SCNMaterial()
        boxMaterial.diffuse.contents = NSColor.gray
        boxGeometry.materials = [boxMaterial]
        
        let boxNode = SCNNode(geometry: boxGeometry)
        let physicsBody = SCNPhysicsBody(type: .kinematic, shape: nil)
        physicsBody.mass = 1.0
        boxNode.physicsBody = physicsBody
        return boxNode
    }
    
    private func createLight() -> SCNNode {
        let light = SCNLight()
        light.type = .ambient  // Can be .directional, .ambient, or .spot depending on needs
        light.color = NSColor.white
        light.intensity = 1000  // Adjust the intensity to fit your scene
        
        let lightNode = SCNNode()
        lightNode.light = light
        lightNode.position = SCNVector3(x: 0, y: 5, z: 10)
        
        return lightNode
    }
}
