import SwiftUI
import ARKit

class RealityKitService: NSObject, ObservableObject, ARSessionDelegate {
    var session: ARSession
    
    @Published var devicePosition: SIMD3<Float> = SIMD3(0, 0, 0)
    @Published var deviceOrientation: SIMD3<Float> = SIMD3(0, 0, 0)
    @Published var linearVelocity: SIMD4<Float> = SIMD4(0, 0, 0, 0)
    @Published var angularVelocity: SIMD3<Float> = SIMD3(0, 0, 0)
    @Published var trackingStatus: ARCamera.TrackingState = .normal
    @Published var anchors: [ARAnchor] = []
    
    // New properties
    @Published var cameraIntrinsics: simd_float3x3 = simd_float3x3(1)
    @Published var fieldOfView: Float = 0.0
    @Published var gravity: SIMD4<Float> = SIMD4(0, 0, 0, 0)

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
        let position = transform.columns.3
        self.devicePosition = SIMD3(position.x, position.y, position.z)

        // Update orientation
        let column0 = transform.columns.0
        let column1 = transform.columns.1
        let column2 = transform.columns.2
        
        let yaw = atan2(column0.y, column0.x)
        let pitch = atan2(-column0.z, sqrt(pow(column1.z, 2) + pow(column2.z, 2)))
        let roll = atan2(column1.z, column2.z)
        
        self.deviceOrientation = SIMD3(pitch, yaw, roll)
        
        // Update velocity, gravity, camera intrinsics, and field of view
        self.linearVelocity = frame.camera.transform.columns.3
        self.angularVelocity = SIMD3(frame.camera.eulerAngles.x, frame.camera.eulerAngles.y, frame.camera.eulerAngles.z)
        self.trackingStatus = frame.camera.trackingState
        self.anchors = session.currentFrame?.anchors ?? []
        
        // Camera intrinsics and field of view
        self.cameraIntrinsics = frame.camera.intrinsics
        self.fieldOfView = frame.camera.intrinsics[1, 1]  // Example for the Y-axis FoV
        
        // Gravity
        self.gravity = frame.camera.transform.columns.2 * -1 // Direction of gravity
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
