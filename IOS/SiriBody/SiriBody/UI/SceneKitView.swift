import SwiftUI
import SceneKit
import Combine

struct SceneKitView: NSViewRepresentable {
    
    @ObservedObject var robitPositionService: RobitPositionService
    @Binding var motorSpeed: (motor1Speed: Int, motor2Speed: Int)
    @State var bag = Set<AnyCancellable>()
    
    func makeCoordinator() -> Coordinator {
        Coordinator(robitPositionService: robitPositionService)
    }
    
    func makeNSView(context: Context) -> SCNView {
        // Create the SCNView
        let scnView = SCNView(frame: .zero)
        guard let scene = SCNScene(named: "SiriBody.obj") else {
            print("Failed to load the scene")
            return scnView
        }
        scnView.scene = scene
        scene.physicsWorld.gravity = SCNVector3(0, -9.8, 0)
        
        print(scene.rootNode.childNodes.count)
        
        if let modelNode = scene.rootNode.childNodes.first {
//            modelNode.position = SCNVector3(10,-100, 30)
            modelNode.scale = SCNVector3(x: 0.01, y: 0.01, z: 0.01)
            context.coordinator.boxNode = modelNode
            
            let camera = SCNCamera()
            camera.zFar = 10000.0
            
            // Create a node to hold the camera
            let cameraNode = SCNNode()
            cameraNode.camera = camera
            cameraNode.eulerAngles = SCNVector3(0, Double.pi, 0)
//            scnView.pointOfView = cameraNode
            
    //        / Adjust the camera's position relative to the model
            

//             Optionally, make the camera look at the model
            
            let boxNode4 = createBox()
            scene.rootNode.addChildNode(boxNode4)
            boxNode4.position = SCNVector3(20, 20, -20)
            
            
            
            
            //Test box
//            let boxGeometry = SCNBox(width: 30, height: 30, length: 30, chamferRadius: 0.01)
//            let boxMaterial = SCNMaterial()
//            boxMaterial.diffuse.contents = NSColor.red
//            boxGeometry.materials = [boxMaterial]
//            let boxNode = SCNNode(geometry: boxGeometry)
            
        
//            modelNode.addChildNode(boxNode)
//            boxNode.position = SCNVector3(0, 150, -35)
            
            modelNode.addChildNode(cameraNode)
            cameraNode.position = SCNVector3(0, 150, -35)
        }
        // Configure the view
        scnView.allowsCameraControl = true
        scnView.backgroundColor = NSColor.black
        
        // Add content to the scene
        
        let boxNode1 = createBox()
        scene.rootNode.addChildNode(boxNode1)
        boxNode1.position = SCNVector3(10, 10, 20)
        
        let boxNode2 = createBox()
        scene.rootNode.addChildNode(boxNode2)
        boxNode2.position = SCNVector3(20, 20, -20)
        
        let boxNode3 = createBox()
        scene.rootNode.addChildNode(boxNode3)
        boxNode3.position = SCNVector3(-10, 10, 20)
        
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
        let boxGeometry = SCNBox(width: 3, height: 17, length: 4, chamferRadius: 0.01)
        let boxMaterial = SCNMaterial()
        boxMaterial.diffuse.contents = NSColor(calibratedRed: Double.random(in: 0...1), green: Double.random(in: 0...1), blue: Double.random(in: 0...1), alpha: 1)
        boxGeometry.materials = [boxMaterial]
        let physicsBody = SCNPhysicsBody(type: .dynamic, shape: nil)
        physicsBody.mass = 1.0
        
        
        
        let boxNode = SCNNode(geometry: boxGeometry)
        //        self.boxNode = boxNode
        //        let physicsBody = SCNPhysicsBody(type: .dynamic, shape: nil)
        //        physicsBody.mass = 1.0
        //        boxNode.physicsBody = physicsBody
        boxNode.physicsBody = physicsBody
        
        return boxNode
    }
    
    private func createFloor() -> SCNNode {
        let boxGeometry = SCNBox(width: 100, height: 0.1, length: 100, chamferRadius: 0.0)
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
    
    class Coordinator: NSObject {
        var robitPositionService: RobitPositionService
        var boxNode: SCNNode?
        private var bag: Set<AnyCancellable> = []
        
        init(robitPositionService: RobitPositionService) {
            self.robitPositionService = robitPositionService
            super.init()
            setupSubscriptions()
        }
        
        private func setupSubscriptions() {
            robitPositionService
                .$robitPosition
                .sink { [weak self] state in
                    self?.updateBox(state.position, state.orientation)
                }
                .store(in: &bag)
        }
        
        private func updateBox(_ position: SIMD3<Float>, _ orientation: SIMD3<Float>) {
            guard let boxNode = boxNode else { return }
            boxNode.position = SCNVector3(x: CGFloat(position.x*10), y: 0.0, z: CGFloat(position.z*10))
            boxNode.eulerAngles = SCNVector3(x: 0.0, y: CGFloat(orientation.z), z: 0.0)
        }
    }
}
