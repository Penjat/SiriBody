import SwiftUI

struct MotionControlView: View {
    @ObservedObject var pidMotionControl: PIDMotionControl
    var body: some View {
        VStack {

            Text("target: \(pidMotionControl.targetRotation)")
            Text("current: \(pidMotionControl.currentAngle)")

            HStack {
                Text("movement:")
                Toggle("motion", isOn: $pidMotionControl.motionEnabled)
            }

            HStack {
                Text("rotation:")
                Toggle("motion", isOn: $pidMotionControl.rotationEnabled)
            }
            PIDControllerView(controller: pidMotionControl.rotationController, name: "rotation PID")

        }.padding()
            .background(.regularMaterial).cornerRadius(8)
    }
}
