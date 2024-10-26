import SwiftUI

struct CommandPanelView: View {
    @EnvironmentObject var appState: AppState
    @State var message = ""
    @State var rotation = 0.0
    @State var x = ""
    @State var y = ""
    var body: some View {
        VStack {
           
            HStack {
                TextField(text: $x) {
                    Text("x:")
                }
                TextField(text: $y) {
                    Text("y:")
                }
            }
            Button {
                if let xDouble = Double(x), let yDouble = Double(y) {
                    print("\(xDouble), \(yDouble)")
                    appState.virtualRobitBrain.sequenceController.motionCommand = Command.moveTo(x: xDouble, z: yDouble)

                }

            } label: {
                Text("set target")
            }

            Slider(value: $rotation, in: -Double.pi...Double.pi)
            Button {

//                commandInteractor.input.send(Command.turnTo(angle: rotation))
            } label: {
                Text("set rotation")
            }
        }
    }
}

#Preview {
    CommandPanelView()
}
