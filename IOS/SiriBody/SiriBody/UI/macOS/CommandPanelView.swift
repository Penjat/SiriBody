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
                    // TODO: Eventually this could be replaced by a list of active robits
                    if sendToVirtual {
                        appState.virtualRobitBrain.sequenceController.motionCommand = Command.moveTo(x: xDouble, z: zDouble)
                    }
                    
                    if sendToPhysical {
                        // TODO: Handle this differently
                        appState.centralService.outputSubject.send(Command.moveTo(x: xDouble, z: zDouble).toData())
                        
                        
                    }
                }

            } label: {
                Text("set target")
            }
            Text("\(rotation)")
            Slider(value: $rotation, in: -Double.pi...Double.pi)
            Button {
                if sendToVirtual {
                    appState.virtualRobitBrain.sequenceController.motionCommand = Command.turnTo(angle: rotation)
                }
                
                if sendToPhysical {
                    appState.centralService.outputSubject.send(Command.turnTo(angle: rotation).toData())
                    appState.rotationResponseMap = PIDResponseMap(targetValue: rotation, dataPoints: [])
                }
                
            } label: {
                Text("set rotation")
            }
            
            Button {
                appState.savePIDResponse()
            } label: {
                Text("Save PID Response")
            }
            
            Button {
                appState.centralService.outputSubject.send(Data([TransferCode.setRotationP.rawValue]) + TransferService.doubleToData(128.78) )
            } label: {
                Text("test send setting")
            }

        }
    }
}

#Preview {
    CommandPanelView()
}
