import SceneKit
import Combine

enum CameraPosition: String, CaseIterable {
    case overhead
    case virtual
    case real
    case side
}

class SceneKitService: NSObject, SCNSceneRendererDelegate, ObservableObject {
    @Published var cameraPosition = CameraPosition.overhead
    @Published var realRobitState = RobitState.zero
    @Published var virtualRobitBody = VirtualRobitBody()

    var mapService: SceneKitMapService!

    var bag = Set<AnyCancellable>()
    
    override init() {
        super.init()
        mapService = SceneKitMapService(scene: scene)
        $cameraPosition
            .sink { [weak self] cameraPosition in
                guard let self else {
                    return
                }

                switch cameraPosition {
                case .real:
                    realRobitCam.addChildNode(camera)
                case .virtual:
                    virtualRobitBody
                        .virtualRobitCam
                        .addChildNode(camera)
                case .overhead:
                    overheadCam.addChildNode(camera)
                case .side:
                    sideCam.addChildNode(camera)
                }
            }
            .store(in: &bag)

        $realRobitState
            .sink { [weak self] state in
            self?.updateRealRobit(state.position, state.orientation)
        }
        .store(in: &bag)
    }

    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
        virtualRobitBody.updateRobit()
    }


    // MARK: Cameras


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

    lazy var sideCam = {
        let cameraNode = SCNNode()
        cameraNode.eulerAngles = SCNVector3(-Double.pi/2, 0, 0)
        cameraNode.position = SCNVector3(0, 0, -90)
        return cameraNode
    }()


    // MARK: Robits


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
        let boxGeometry = SCNBox(width: 100, height: 1, length: 100, chamferRadius: 0.0)
        let boxMaterial = SCNMaterial()
        boxMaterial.diffuse.contents = NSColor.gray
        boxGeometry.materials = [boxMaterial]

        let boxNode = SCNNode(geometry: boxGeometry)
        let physicsBody = SCNPhysicsBody(type: .kinematic, shape: nil)
        physicsBody.mass = 1.0
        boxNode.physicsBody = physicsBody
        boxNode.position = SCNVector3(x: 0, y: -1, z: 0)
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


    // MARK: Cameras


    lazy var scene = {
        let scene = SCNScene()
        scene.physicsWorld.gravity = SCNVector3(0, -9.8, 0)
        scene.rootNode.addChildNode(mainLight)
        scene.rootNode.addChildNode(mainFloor)
        scene.rootNode.addChildNode(overheadCam)
        
        if let virtualRobit = virtualRobitBody.node {
            scene.rootNode.addChildNode(virtualRobit)
        }
        
        if let realRobit {
            scene.rootNode.addChildNode(realRobit)
            realRobit.position = SCNVector3(10, 0, 15)
        }
        
        let boxNode1 = createBox(color: .red)
        scene.rootNode.addChildNode(boxNode1)
        boxNode1.position = SCNVector3(10, 0.1, 10)

        let boxNode2 = createBox(color: .blue)
        scene.rootNode.addChildNode(boxNode2)
        boxNode2.position = SCNVector3(10, 0.1, -10)

        let boxNode3 = createBox(color: .green)
        scene.rootNode.addChildNode(boxNode3)
        boxNode3.position = SCNVector3(-10, 0.1, 10)

        let boxNode4 = createBox(color: .yellow)
        scene.rootNode.addChildNode(boxNode4)
        boxNode4.position = SCNVector3(-10, 0.1, -10)

        return scene
    }()

    private func updateRealRobit(_ position: SIMD3<Float>, _ orientation: SIMD3<Float>) {

        realRobit?.position = SCNVector3(x: CGFloat(position.x*10), y: 0.0, z: CGFloat(position.z*10))
        realRobit?.eulerAngles = SCNVector3(x: 0.0, y: CGFloat(orientation.z), z: 0.0)
    }

    private func createBox(color: NSColor) -> SCNNode {
        let boxGeometry = SCNBox(width: 3, height: 1, length: 4, chamferRadius: 0.01)
        let boxMaterial = SCNMaterial()
        boxMaterial.diffuse.contents = color
        boxGeometry.materials = [boxMaterial]
//        let physicsBody = SCNPhysicsBody(type: .dynamic, shape: nil)
//        physicsBody.mass = 1.0
        
        let boxNode = SCNNode(geometry: boxGeometry)
//        boxNode.physicsBody = physicsBody
        
        return boxNode
    }

    public func resetVirtualRobitPosition(_ position: SCNVector3? = nil, _ orientation: SCNVector3? = nil) {
        print(virtualRobitBody.node?.position)
        virtualRobitBody.node?.position = position ?? SCNVector3(x: 0.0, y: 0.0, z: 0.0)
        virtualRobitBody.node?.eulerAngles = orientation ?? SCNVector3(x: 0.0, y: 0.0, z: Double.pi/2)
        virtualRobitBody.node?.physicsBody?.velocity = SCNVector3(x: 0.0, y: 0.0, z: 0.0)
    }

    public func resetVirtualRobitPosition(_ position: SIMD3<Float>, _ orientation: SIMD3<Float>) {

        virtualRobitBody.node?.position = position.asSCNVector3
        virtualRobitBody.node?.eulerAngles = orientation.asSCNVector3
        virtualRobitBody.node?.physicsBody?.velocity = SCNVector3(x: 0.0, y: 0.0, z: 0.0)
        print(virtualRobitBody.node?.position)
    }
}
