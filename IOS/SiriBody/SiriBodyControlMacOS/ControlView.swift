import SwiftUI
import Combine
import SceneKit

struct ControlView: View {
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var sceneKitInteractor: SceneKitInteractor

    @State var bag = Set<AnyCancellable>()
    
    var body: some View {
        VStack {
            SceneKitView(interactor: sceneKitInteractor)

            HStack {
                JoystickView(motorSpeed: $appState.sceneKitInteractor.virtualRobitBody.motorSpeed).frame(width: 420)
                Spacer()
                VStack {
                    Picker(selection: $sceneKitInteractor.cameraPosition) {
                        ForEach(CameraPosition.allCases, id: \.self) { cameraPosition in
                            Text(cameraPosition.rawValue).tag(cameraPosition)
                        }
                    } label: {
                        Text("camera")
                    }.pickerStyle(SegmentedPickerStyle())

//                    VirtualRobiPanelView()


                    Text(robitState)
                    BluetoothStatusView()
                }.frame(width: 420)
            }
            
        }
    }
    var robitState: String {
        return "x:\(appState.virtualRobitBrain.state.position.x), y: \(appState.virtualRobitBrain.state.position.y), z:\(appState.virtualRobitBrain.state.position.z), pitch:\(appState.virtualRobitBrain.state.position.x), yaw: \(appState.virtualRobitBrain.state.position.y), roll:\(appState.virtualRobitBrain.state.position.z)"
    }
}

#Preview {
    ControlView()
}
