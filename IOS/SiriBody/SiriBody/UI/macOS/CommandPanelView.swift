import SwiftUI

struct CommandPanelView: View {
    @EnvironmentObject var appState: AppState
    @State var message = ""
    @State var rotation = 0.0
    @State var x = ""
    @State var z = ""
    @State var sendToVirtual = false
    @State var sendToPhysical = false
    
    @State var rotationController = PIDController()
    
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
            
            // TODO: clean up this mess
            HStack {
                Button {
                    let rotation = Double(appState.sceneKitService.realRobitState.orientation.z) + Double.pi/2
                    appState.centralService.outputSubject.send(Command.turnTo(angle: rotation).toData())
                    appState.rotationResponseMap = PIDResponseMap(targetValue: rotation, dataPoints: [])
                } label: {
                    Text("90 R")
                }
                Button {
                    let rotation = Double(appState.sceneKitService.realRobitState.orientation.z) - Double.pi/2
                    appState.centralService.outputSubject.send(Command.turnTo(angle: rotation).toData())
                    appState.rotationResponseMap = PIDResponseMap(targetValue: rotation, dataPoints: [])
                } label: {
                    Text("90 L")
                }
                
                Button {
                    let rotation = Double(appState.sceneKitService.realRobitState.orientation.z) + Double.pi
                    appState.centralService.outputSubject.send(Command.turnTo(angle: rotation).toData())
                    appState.rotationResponseMap = PIDResponseMap(targetValue: rotation, dataPoints: [])
                } label: {
                    Text("180 R")
                }
                Button {
                    let rotation = Double(appState.sceneKitService.realRobitState.orientation.z) - Double.pi
                    appState.centralService.outputSubject.send(Command.turnTo(angle: rotation).toData())
                    appState.rotationResponseMap = PIDResponseMap(targetValue: rotation, dataPoints: [])
                } label: {
                    Text("180 L")
                }

            }
            
            PIDControllerView(controller: rotationController, name: "Real Robit Rotation Controller")
            
            Button {
                appState.centralService.outputSubject.send(Data([TransferCode.setRotationP.rawValue]) + TransferService.doubleToData(rotationController.pConstant) )
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    appState.centralService.outputSubject.send(Data([TransferCode.setRotationI.rawValue]) + TransferService.doubleToData(rotationController.iConstant) )
                }
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                    appState.centralService.outputSubject.send(Data([TransferCode.setRotationD.rawValue]) + TransferService.doubleToData(rotationController.dConstant) )
                }
                
            } label: {
                Text("test send setting")
            }

        }
    }
}

#Preview {
    CommandPanelView()
}
