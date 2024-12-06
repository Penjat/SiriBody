import SwiftUI

struct CommandPanelView: View {
    @EnvironmentObject var appState: AppState
    @State var message = ""
    @State var rotation = 0.0
    @State var x = ""
    @State var z = ""
    @State var sendToVirtual = false
    @State var sendToPhysical = false
    
    var body: some View {
        VStack {
            
            HStack {
                Toggle("Physical", isOn: $sendToPhysical)
                CentralStatusView()
            }.padding()
            
            Toggle("Virtual", isOn: $sendToVirtual)
            
            HStack {
                TextField(text: $x) {
                    Text("x:")
                }
                TextField(text: $z) {
                    Text("y:")
                }
            }
            Button {
                if let xDouble = Double(x), let zDouble = Double(z) {
                    print("\(xDouble), \(zDouble)")
                    if sendToVirtual {
                        appState.virtualRobitBrain.sequenceController.motionCommand = Command.moveTo(x: xDouble, z: zDouble)
                    }
                    
                    if sendToPhysical {
                        appState.centralService.outputSubject.send(Command.moveTo(x: xDouble, z: zDouble).toData())
                    }
                }

            } label: {
                Text("set target")
            }

            Slider(value: $rotation, in: -Double.pi...Double.pi)
            Button {
                if sendToVirtual {
                    appState.virtualRobitBrain.sequenceController.motionCommand = Command.turnTo(angle: rotation)
                }
                
                if sendToPhysical {
                    appState.centralService.outputSubject.send(Command.turnTo(angle: rotation).toData())
                }
                
            } label: {
                Text("set rotation")
            }

        }
    }
}

#Preview {
    CommandPanelView()
}
