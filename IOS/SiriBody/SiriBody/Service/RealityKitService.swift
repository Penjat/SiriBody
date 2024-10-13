import SwiftUI
import ARKit

struct RobitState {
    let devicePosition: SIMD3<Float>
    let deviceOrientation: SIMD3<Float>
    let trackingStatus: ARCamera.TrackingState?
    let linearVelocity: SIMD3<Float>?
    let gravity: SIMD4<Float>
}

class RealityKitService: NSObject, ObservableObject, ARSessionDelegate {
    @Published var robitState: RobitState?
    
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
        
        // Update orientation
        let column0 = transform.columns.0
        let column1 = transform.columns.1
        let column2 = transform.columns.2
        
        let yaw = atan2(column0.y, column0.x)
        let pitch = atan2(-column0.z, sqrt(pow(column1.z, 2) + pow(column2.z, 2)))
        let roll = atan2(column1.z, column2.z)

        
        // Calculate linear velocity
        var linearVelocity: SIMD3<Float>?
        if let lastPosition = lastPosition, let lastUpdateTime = lastUpdateTime {
            let deltaTime = Date().timeIntervalSince(lastUpdateTime)
            if deltaTime > 0 {
                let deltaPosition = position - lastPosition
                linearVelocity = deltaPosition / Float(deltaTime)
            }
        }
        
        // Update last position and time
        self.lastPosition = position
        self.lastUpdateTime = Date()
        
        self.robitState = 
        RobitState(
            devicePosition: position,
            deviceOrientation: SIMD3(pitch, yaw, roll),
            trackingStatus: frame.camera.trackingState,
            linearVelocity: linearVelocity,
            gravity: transform.columns.2 * -1)
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

