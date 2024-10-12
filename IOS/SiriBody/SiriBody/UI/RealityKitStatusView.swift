import SwiftUI
import simd

struct RealityKitStatusView: View {
    @EnvironmentObject var realityKitService: RealityKitService
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            
                Text("Status: \(trackingStatusDescription)")
                Text("x: \(realityKitService.devicePosition.x, specifier: "%.2f"), y: \(realityKitService.devicePosition.y, specifier: "%.2f"), z: \(realityKitService.devicePosition.z, specifier: "%.2f")")
                
                
                Text("Pitch: \(realityKitService.deviceOrientation.x, specifier: "%.2f"), Yaw: \(realityKitService.deviceOrientation.y, specifier: "%.2f"), Roll: \(realityKitService.deviceOrientation.z, specifier: "%.2f")")
                
                
                Text("x: \(realityKitService.linearVelocity.x, specifier: "%.2f"), y: \(realityKitService.linearVelocity.y, specifier: "%.2f"), z: \(realityKitService.linearVelocity.z, specifier: "%.2f")")
            
        }
        .padding()
        .background(.regularMaterial).cornerRadius(8)
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
    private func matrixDescription(_ matrix: simd_float4x4) -> String {
        """
        [\(matrix.columns.0.x), \(matrix.columns.0.y), \(matrix.columns.0.z), \(matrix.columns.0.w)]
        [\(matrix.columns.1.x), \(matrix.columns.1.y), \(matrix.columns.1.z), \(matrix.columns.1.w)]
        [\(matrix.columns.2.x), \(matrix.columns.2.y), \(matrix.columns.2.z), \(matrix.columns.2.w)]
        [\(matrix.columns.3.x), \(matrix.columns.3.y), \(matrix.columns.3.z), \(matrix.columns.3.w)]
        """
    }
}
