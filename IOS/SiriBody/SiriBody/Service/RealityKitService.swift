import SwiftUI
import ARKit

class RealityKitService: NSObject, ObservableObject, ARSessionDelegate {
    
    
    @Published var devicePosition: SIMD3<Float> = SIMD3(0, 0, 0)
    @Published var deviceOrientation: SIMD3<Float> = SIMD3(0, 0, 0)
    @Published var linearVelocity: SIMD3<Float> = SIMD3(0, 0, 0)
    @Published var trackingStatus: ARCamera.TrackingState = .normal
    @Published var gravity: SIMD4<Float> = SIMD4(0, 0, 0, 0)
    
    private var lastPosition: SIMD3<Float>?
    private var lastUpdateTime: Date?
    private var session: ARSession

    override init() {
        self.session = ARSession()
        super.init()
        session.delegate = self
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = []
        session.run(configuration)
    }
    
    

    func session(_ session: ARSession, didUpdate frame: ARFrame) {
        let transform = frame.camera.transform
        let position = SIMD3(transform.columns.3.x, transform.columns.3.y, transform.columns.3.z)
        self.devicePosition = position

        // Update orientation
        let column0 = transform.columns.0
        let column1 = transform.columns.1
        let column2 = transform.columns.2
        
        let yaw = atan2(column0.y, column0.x)
        let pitch = atan2(-column0.z, sqrt(pow(column1.z, 2) + pow(column2.z, 2)))
        let roll = atan2(column1.z, column2.z)
        
        self.deviceOrientation = SIMD3(pitch, yaw, roll)
        
        // Calculate linear velocity
        if let lastPosition = lastPosition, let lastUpdateTime = lastUpdateTime {
            let deltaTime = Date().timeIntervalSince(lastUpdateTime)
            if deltaTime > 0 {
                let deltaPosition = position - lastPosition
                self.linearVelocity = deltaPosition / Float(deltaTime)
            }
        }
        
        // Update last position and time
        self.lastPosition = position
        self.lastUpdateTime = Date()
        
        // Angular velocity can be handled similarly, but here we use camera.eulerAngles directly for simplicity
//        self.angularVelocity = SIMD3(frame.camera.eulerAngles.x, frame.camera.eulerAngles.y, frame.camera.eulerAngles.z)
        self.trackingStatus = frame.camera.trackingState
//        self.anchors = session.currentFrame?.anchors ?? []
        
        // Camera intrinsics and field of view
//        self.cameraIntrinsics = frame.camera.intrinsics
//        self.fieldOfView = frame.camera.intrinsics[1, 1]  // Example for the Y-axis FoV
        
        // Gravity
        self.gravity = transform.columns.2 * -1 // Direction of gravity
    }

    
    func pauseTracking() {
        session.pause()
    }
    
    func resumeTracking() {
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = []
        session.run(configuration)
    }
}
