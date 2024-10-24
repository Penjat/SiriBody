import SwiftUI
import Combine
import SceneKit

struct ControlView: View {
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var sceneKitInteractor: SceneKitInteractor
    @EnvironmentObject var virtualRobitBrain: RobitBrain

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

                    VirtualRobiPanelView()
                    CommandPanelView()
                    PIDControlView(pidMotionControl: appState.pidController)

                    Text(robitState)
                    BluetoothStatusView()
                }.frame(width: 420)
            }
            
        }
    }
    var robitState: String {
        return "x:\(String(format: "%.2f", sceneKitInteractor.virtualRobitBody.state.position.x)), y: \(String(format: "%.2f", sceneKitInteractor.virtualRobitBody.state.position.y)), z:\(String(format: "%.2f", sceneKitInteractor.virtualRobitBody.state.position.z)), pitch:\(String(format: "%.2f", sceneKitInteractor.virtualRobitBody.state.orientation.x)), yaw: \(String(format: "%.2f", sceneKitInteractor.virtualRobitBody.state.orientation.y)), roll:\(String(format: "%.2f", sceneKitInteractor.virtualRobitBody.state.orientation.z))"
    }
}

#Preview {
    ControlView()
}
