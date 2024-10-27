import SwiftUI

struct MotionControlView: View {
    @ObservedObject var pidMotionControl: MotionOutputInteractor
    var body: some View {
        VStack {
            Text("current mode:")
            switch pidMotionControl.mode {
            case .idle:
                Text("Idle")
            case .faceAngle(let angle):
                Text("faceAngle: \(angle)")

            case .facePosition(let position):
                Text("face postition: \(position.x), \(position.z)")
            case .moveTo((let x, let z)):
                Text("moveTo: \(x), \(z)")
            }

            Text("current: \(pidMotionControl.currentAngle)")
            Text("target: \(pidMotionControl.targetRotation)")
            Text("delta: \(pidMotionControl.angleDifference)")
            HStack {
                Text("movement:")
                Toggle("motion", isOn: $pidMotionControl.motionEnabled)
            }

            HStack {
                Text("rotation:")
                Toggle("motion", isOn: $pidMotionControl.rotationEnabled)
            }

            PIDControllerView(controller: pidMotionControl.rotationController, name: "rotation PID")
            PIDControllerView(controller: pidMotionControl.translationController, name: "transation PID")

            Slider(value: $pidMotionControl.moveThreshold, in: 0.0...Double.pi)

        }.padding()
            .background(.regularMaterial).cornerRadius(8)
    }
}
