import SwiftUI
import simd

struct RealityKitStatusView: View {
    @EnvironmentObject var realityKitService: RealityKitService
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            if let robitState = realityKitService.robitState {
                Text("Status: \(trackingStatusDescription)")
                Text("x: \(robitState.devicePosition.x, specifier: "%.2f"), y: \(robitState.devicePosition.y, specifier: "%.2f"), z: \(robitState.devicePosition.z, specifier: "%.2f")")
                
                
                Text("Pitch: \(robitState.deviceOrientation.x, specifier: "%.2f"), Yaw: \(robitState.deviceOrientation.y, specifier: "%.2f"), Roll: \(robitState.deviceOrientation.z, specifier: "%.2f")")
                
                if let velocity = robitState.linearVelocity {
                    Text("x: \(velocity.x, specifier: "%.2f"), y: \(velocity.y, specifier: "%.2f"), z: \(velocity.z, specifier: "%.2f")")
                } else {
                    Text("no data")
                }
            }
        }
        .padding()
        .background(.regularMaterial).cornerRadius(8)
        .navigationTitle("RealityKit Service Data")
    }
    
    // Helper to format tracking status
    private var trackingStatusDescription: String {
        switch realityKitService.robitState?.trackingStatus {
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
        default:
            return "Unknown"
        }
    }
    
    // Helper to format a matrix
    private func matrixDescription(_ matrix: simd_float4x4) -> String {
        """
        [\(matrix.columns.0.x), \(matrix.columns.0.y), \(matrix.columns.0.z), \(matrix.columns.0.w)]
        [\(matrix.columns.1.x), \(matrix.columns.1.y), \(matrix.columns.1.z), \(matrix.columns.1.w)]
        [\(matrix.columns.2.x), \(matrix.columns.2.y), \(matrix.columns.2.z), \(matrix.columns.2.w)]
        [\(matrix.columns.3.x), \(matrix.columns.3.y), \(matrix.columns.3.z), \(matrix.columns.3.w)]
        """
    }
}
