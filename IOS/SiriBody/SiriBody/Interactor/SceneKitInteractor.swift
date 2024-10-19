import SceneKit
import Combine

enum CameraPosition: String, CaseIterable {
    case virtual
    case real
    case overhead
}

class SceneKitInteractor: ObservableObject {
    @Published var realRobitPosition = RobitPosition(position: SIMD3<Float>(0, 0, 0), orientation: SIMD3<Float>(0, 0, 0))
    @Published var cameraPosition = CameraPosition.virtual
    var bag = Set<AnyCancellable>()
    let virtualRobitInteractor: VirtualRobitInteractor

    init(virtualRobitInteractor: VirtualRobitInteractor) {
        self.virtualRobitInteractor = virtualRobitInteractor
    }
    
    lazy var camera = {
        let cameraNode = SCNNode()
        let camera = SCNCamera()
        cameraNode.camera = camera
        camera.zFar = 10000.0
        
        return cameraNode
    }()

    lazy var realRobitCam = {
        let cameraNode = SCNNode()
        cameraNode.eulerAngles = SCNVector3(0, Double.pi, 0)
        return cameraNode
    }()
    
    lazy var overheadCam = {
        let cameraNode = SCNNode()
        cameraNode.eulerAngles = SCNVector3(-Double.pi/2, 0, 0)
        cameraNode.position = SCNVector3(0, 50, 0)
        return cameraNode
    }()
    
    lazy var scene = {
        let scene = SCNScene()
        scene.physicsWorld.gravity = SCNVector3(0, -9.8, 0)
        scene.rootNode.addChildNode(mainLight)
        scene.rootNode.addChildNode(mainFloor)
        scene.rootNode.addChildNode(overheadCam)
        
        if let virtualRobit = virtualRobitInteractor.virtualRobit {
            scene.rootNode.addChildNode(virtualRobit)
        }
        
        if let realRobit {
            scene.rootNode.addChildNode(realRobit)
            realRobit.position = SCNVector3(10, 0, 15)
        }
        
        let boxNode1 = createBox()
        scene.rootNode.addChildNode(boxNode1)
        boxNode1.position = SCNVector3(10, 10, 20)
        
        let boxNode2 = createBox()
        scene.rootNode.addChildNode(boxNode2)
        boxNode2.position = SCNVector3(20, 20, -20)
        
        let boxNode3 = createBox()
        scene.rootNode.addChildNode(boxNode3)
        boxNode3.position = SCNVector3(-10, 10, 20)
        
        let boxNode4 = createBox()
        scene.rootNode.addChildNode(boxNode4)
        boxNode4.position = SCNVector3(20, 20, -20)
        
        $realRobitPosition
            .sink { [weak self] state in
                self?.updateVirtualRobit(state.position, state.orientation)
            }
            .store(in: &bag)
        
        $cameraPosition
            .sink { [weak self] cameraPosition in
                guard let self else {
                    return
                }
                
                switch cameraPosition {
                case .real:
                    realRobitCam.addChildNode(camera)
                case .virtual:
                    virtualRobitInteractor.virtualRobitCam.addChildNode(camera)
                case .overhead:
                    overheadCam.addChildNode(camera)
                }
            }
            .store(in: &bag)
        
        return scene
    }()
    
    
    
    lazy var realRobit: SCNNode? = {
        guard let scene = SCNScene(named: "SiriBodyReal.obj"), let modelNode = scene.rootNode.childNodes.first else {
            print("Error: Failed to load the scene")
            return nil
        }
        modelNode.scale = SCNVector3(0.01, 0.01, 0.01)
        modelNode.addChildNode(realRobitCam)
        realRobitCam.position = SCNVector3(0, 150, -35)
       
        return modelNode
    }()
    
    lazy var mainFloor = {
        let boxGeometry = SCNBox(width: 100, height: 0.1, length: 100, chamferRadius: 0.0)
        let boxMaterial = SCNMaterial()
        boxMaterial.diffuse.contents = NSColor.gray
        boxGeometry.materials = [boxMaterial]
        
        let boxNode = SCNNode(geometry: boxGeometry)
        let physicsBody = SCNPhysicsBody(type: .kinematic, shape: nil)
        physicsBody.mass = 1.0
        boxNode.physicsBody = physicsBody
        return boxNode
    }()
    
    lazy var mainLight = {
        let light = SCNLight()
        light.type = .ambient
        light.color = NSColor.white
        light.intensity = 1000
        
        let lightNode = SCNNode()
        lightNode.light = light
        lightNode.position = SCNVector3(x: 0, y: 5, z: 10)
        
        return lightNode
    }()
    
    private func updateVirtualRobit(_ position: SIMD3<Float>, _ orientation: SIMD3<Float>) {
        guard let virtualRobit = virtualRobitInteractor.virtualRobit else { return }
        virtualRobit.position = SCNVector3(x: CGFloat(position.x*10), y: 0.0, z: CGFloat(position.z*10))
        virtualRobit.eulerAngles = SCNVector3(x: 0.0, y: CGFloat(orientation.z), z: 0.0)
    }
    
    //TODO: remove this function
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

    public func resetVirtualRobitPosition(_ position: SCNVector3? = nil, _ orientation: SCNVector3? = nil) {
        virtualRobitInteractor.virtualRobit?.position = position ?? SCNVector3(x: 0.0, y: 0.0, z: 0.0)
        virtualRobitInteractor.virtualRobit?.eulerAngles = orientation ?? SCNVector3(x: 0.0, y: 0.0, z: 0.0)
        virtualRobitInteractor.virtualRobit?.physicsBody?.velocity = SCNVector3(x: 0.0, y: 0.0, z: 0.0)
    }
}
