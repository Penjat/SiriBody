import SwiftUI

struct PIDControlView: View {
    @ObservedObject var pidMotionControl: PIDMotionControl
    var body: some View {
        VStack {
            Text("movement:")
            HStack {
                VStack {
                    Toggle("", isOn: $pidMotionControl.pDistanceIsOn)
                    Text("\(String(format: "%.2f", pidMotionControl.kpDistance))")
                    //                    Text("\(String(format: "%.2f", pidMotionControl.pOutput))").monospaced()
                    Slider(value: $pidMotionControl.kpDistance, in: 0.5...2000).disabled(!pidMotionControl.pDistanceIsOn)
                }

                VStack {
                    Toggle("", isOn: $pidMotionControl.iDistanceIsOn)
                    Text("\(String(format: "%.2f", pidMotionControl.kiDistance))")
                    //                    Text("\(String(format: "%.2f", pidMotionControl.iOutput))").monospaced()
                    Slider(value: $pidMotionControl.kiDistance, in: 0.01...2000).disabled(!pidMotionControl.iDistanceIsOn)
                }

                VStack {
                    Toggle("", isOn: $pidMotionControl.dDistanceIsOn)
                    Text("\(String(format: "%.2f", pidMotionControl.kdDistance))")
                    //                    Text("\(String(format: "%.2f", pidMotionControl.dOutput))").monospaced()
                    Slider(value: $pidMotionControl.kdDistance, in: 0.5...2000).disabled(!pidMotionControl.dDistanceIsOn)
                }

            }.padding()
                .background(.regularMaterial).cornerRadius(8)
            Text("movement+angle:")
            HStack {
                VStack {
                    Toggle("", isOn: $pidMotionControl.pAngleIsOn)
                    Text("\(String(format: "%.2f", pidMotionControl.kpAngle))")
                    //                    Text("\(String(format: "%.2f", pidMotionControl.pOutput))").monospaced()
                    Slider(value: $pidMotionControl.kpAngle, in: 0.5...200).disabled(!pidMotionControl.pAngleIsOn)
                }

                VStack {
                    Toggle("", isOn: $pidMotionControl.iAngleIsOn)
                    Text("\(String(format: "%.2f", pidMotionControl.kiAngle))")
                    //                    Text("\(String(format: "%.2f", pidMotionControl.iOutput))").monospaced()
                    Slider(value: $pidMotionControl.kiAngle, in: 0.01...200).disabled(!pidMotionControl.iAngleIsOn)
                }

                VStack {
                    Toggle("", isOn: $pidMotionControl.dAngleIsOn)
                    Text("\(String(format: "%.2f", pidMotionControl.kdAngle))")
                    //                    Text("\(String(format: "%.2f", pidMotionControl.dOutput))").monospaced()
                    Slider(value: $pidMotionControl.kdAngle, in: 0.5...200).disabled(!pidMotionControl.dAngleIsOn)
                }

            }.padding()
                .background(.regularMaterial).cornerRadius(8)
        }
    }
}
