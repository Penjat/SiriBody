import SwiftUI
import Combine

struct RobitView: View {
    @EnvironmentObject var appState: AppState

    @State var motionEnabled = false
    @State var bag = Set<AnyCancellable>()
    
    var body: some View {
        VStack {
            Text("Robit View")
            
            PeripheralStatusView()
            CentralStatusView()
            RealityKitStatusView(realityKitState: $appState.realityKitState)
            
            PIDControllerView(controller: appState.robitBrain.motionController.rotationController, name: "Rotation Controller")
            PIDControllerView(controller: appState.robitBrain.motionController.translationController, name: "Translation Controller")
            
            HStack {
                Button(action: {
                    appState.robitBrain.sequenceController.motionCommand = .turnTo(angle: 0.0)
                }, label: {
                    Text("0,0")
                })
            }
        }
    }
}

#Preview {
    RobitView()
}
