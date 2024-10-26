import SwiftUI

struct PIDControllerView: View {

    @ObservedObject var controller: PIDController
    let name: String
    var body: some View {
        VStack {
            HStack {
                VStack {
                    Toggle("", isOn: $controller.pIsOn)
                    Text("\(String(format: "%.2f", controller.pConstant))")
                    //                    Text("\(String(format: "%.2f", pidMotionControl.pOutput))").monospaced()
                    Slider(value: $controller.pConstant, in: 0.5...2000).disabled(!controller.pIsOn)
                }

                VStack {
                    Toggle("", isOn: $controller.pIsOn)
                    Text("\(String(format: "%.2f", controller.iConstant))")
                    //                    Text("\(String(format: "%.2f", pidMotionControl.pOutput))").monospaced()
                    Slider(value: $controller.iConstant, in: 0.5...2000).disabled(!controller.pIsOn)
                }

                VStack {
                    Toggle("", isOn: $controller.pIsOn)
                    Text("\(String(format: "%.2f", controller.dConstant))")
                    //                    Text("\(String(format: "%.2f", pidMotionControl.pOutput))").monospaced()
                    Slider(value: $controller.dConstant, in: 0.5...2000).disabled(!controller.pIsOn)
                }
            }
            .padding()
            .background(Color(red: 0.2, green: 0.2, blue: 0.2, opacity: 0.3))
                .cornerRadius(8)
        }
    }
}