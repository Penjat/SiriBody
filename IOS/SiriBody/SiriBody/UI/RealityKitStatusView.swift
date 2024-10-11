import SwiftUI
import simd

struct RealityKitStatusView: View {
    @EnvironmentObject var realityKitService: RealityKitService
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Group {
                Text("Device Position:")
                Text("x: \(realityKitService.devicePosition.x, specifier: "%.2f"), y: \(realityKitService.devicePosition.y, specifier: "%.2f"), z: \(realityKitService.devicePosition.z, specifier: "%.2f")")
                
                Text("Device Orientation (Pitch, Yaw, Roll):")
                Text("Pitch: \(realityKitService.deviceOrientation.x, specifier: "%.2f"), Yaw: \(realityKitService.deviceOrientation.y, specifier: "%.2f"), Roll: \(realityKitService.deviceOrientation.z, specifier: "%.2f")")
                
                Text("Linear Velocity:")
                Text("x: \(realityKitService.linearVelocity.x, specifier: "%.2f"), y: \(realityKitService.linearVelocity.y, specifier: "%.2f"), z: \(realityKitService.linearVelocity.z, specifier: "%.2f")")
                
                Text("Angular Velocity:")
                Text("x: \(realityKitService.angularVelocity.x, specifier: "%.2f"), y: \(realityKitService.angularVelocity.y, specifier: "%.2f"), z: \(realityKitService.angularVelocity.z, specifier: "%.2f")")
            }
            
            Divider()
            
//            Group {
//                Text("Tracking Status:")
//                Text("\(trackingStatusDescription)")
//                
//                Text("Camera Intrinsics:")
//                Text("\(matrixDescription(realityKitService.cameraIntrinsics))")
//                
//                Text("Field of View:")
//                Text("\(realityKitService.fieldOfView, specifier: "%.2f") degrees")
//                
//                Text("Gravity Vector:")
//                Text("x: \(realityKitService.gravity.x, specifier: "%.2f"), y: \(realityKitService.gravity.y, specifier: "%.2f"), z: \(realityKitService.gravity.z, specifier: "%.2f")")
//            }
        }
        .padding()
        .navigationTitle("RealityKit Service Data")
    }
    
    // Helper to format tracking status
    private var trackingStatusDescription: String {
        switch realityKitService.trackingStatus {
        case .notAvailable:
            return "Not Available"
        case .normal:
            return "Normal"
        case .limited(let reason):
            switch reason {
            case .excessiveMotion:
                return "Limited: Excessive Motion"
            case .insufficientFeatures:
                return "Limited: Insufficient Features"
            case .initializing:
                return "Limited: Initializing"
            case .relocalizing:
                return "Limited: Relocalizing"
            @unknown default:
                return "Unknown"
            }
        }
    }
    
    // Helper to format a matrix
//    private func matrixDescription(_ matrix: simd_float4x4) -> String {
//        """
//        [\(matrix.columns.0.x, specifier: "%.2f"), \(matrix.columns.0.y, specifier: "%.2f"), \(matrix.columns.0.z, specifier: "%.2f"), \(matrix.columns.0.w, specifier: "%.2f")]
//        [\(matrix.columns.1.x, specifier: "%.2f"), \(matrix.columns.1.y, specifier: "%.2f"), \(matrix.columns.1.z, specifier: "%.2f"), \(matrix.columns.1.w, specifier: "%.2f")]
//        [\(matrix.columns.2.x, specifier: "%.2f"), \(matrix.columns.2.y, specifier: "%.2f"), \(matrix.columns.2.z, specifier: "%.2f"), \(matrix.columns.2.w, specifier: "%.2f")]
//        [\(matrix.columns.3.x, specifier: "%.2f"), \(matrix.columns.3.y, specifier: "%.2f"), \(matrix.columns.3.z, specifier: "%.2f"), \(matrix.columns.3.w, specifier: "%.2f")]
//        """
//    }
}
