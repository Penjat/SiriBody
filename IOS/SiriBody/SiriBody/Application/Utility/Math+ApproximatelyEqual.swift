import Foundation
import SceneKit

func approximatelyEqual(_ a: Double, _ b: Double, tolerance: Double = 0.01) -> Bool {
    return abs(a - b) < tolerance
}

extension SCNNode {
    var worldForward: SCNVector3 {
        let node = self.presentation  // Use the presentation node for the current state
        let transform = node.transform

        // Extract the forward vector (negative Z-axis) from the node's transform matrix
        let forward = SCNVector3(-transform.m31, -transform.m32, -transform.m33)
        return forward.normalized()
    }
}

extension SCNVector3 {
    // Helper method to normalize an SCNVector3
    func normalized() -> SCNVector3 {
        let length = sqrt(x * x + y * y + z * z)
        guard length != 0 else { return self }
        return SCNVector3(x / length, y / length, z / length)
    }
}

extension SIMD3<Float> {
    var asSCNVector3: SCNVector3 {
        return SCNVector3(self.x, self.y, self.z)
    }
}

extension SCNVector3 {
    var asSIMD3Float: SIMD3<Float> {
        return SIMD3<Float>(Float(self.x), Float(self.y), Float(self.z))
    }
}
