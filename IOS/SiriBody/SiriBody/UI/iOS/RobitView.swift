import SwiftUI
import Combine

struct RobitView: View {
    @EnvironmentObject var appState: AppState

    @State var motionEnabled = false
    @State var bag = Set<AnyCancellable>()
    @State var editPidModal = false
    
    var body: some View {
        VStack {
            
            PeripheralStatusView().padding()
            CentralStatusView().padding()
            Spacer()
//            RealityKitStatusView(realityKitState: $appState.realityKitState)
            RobitStatusView()
            
            CommandView()
            
            Spacer()
            Button {
                editPidModal.toggle()
            } label: {
                Text("edit PID controllers")
            }
            Spacer()
            
        }.sheet(isPresented: $editPidModal) {
            VStack {
                Text("Max speed \(appState.robitBrain.motionController.maxMotorSpeed)")
                Slider(value: $appState.robitBrain.motionController.maxMotorSpeed, in: 0...255) {
                    Text("Max Spped")
                }
                
                PIDControllerView(controller: appState.robitBrain.motionController.rotationController, name: "Rotation Controller")
                    .padding()
                
                PIDControllerView(controller: appState.robitBrain.motionController.translationController, name: "Translation Controller")
                    .padding()
                HStack {
                    Button(action: {
                        appState.robitBrain.sequenceController.motionCommand = .turnTo(angle: 0.0)
                    }, label: {
                        Text("0")
                    })
                    
                    Button(action: {
                        appState.robitBrain.sequenceController.motionCommand = .turnTo(angle: Double.pi)
                    }, label: {
                        Text("π")
                    })
                    
                    Button(action: {
                        appState.robitBrain.sequenceController.motionCommand = .turnTo(angle: Double.pi/2)
                    }, label: {
                        Text("+π/2")
                    })
                    
                    Button(action: {
                        appState.robitBrain.sequenceController.motionCommand = .turnTo(angle: -Double.pi/2)
                    }, label: {
                        Text("-π/2")
                    })
                }.padding()
            }
        }
    }
}

#Preview {
    RobitView()
}
