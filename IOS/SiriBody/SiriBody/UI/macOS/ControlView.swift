import SwiftUI
import Combine
import SceneKit

struct ControlView: View {
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var sceneKitInteractor: SceneKitService
    @EnvironmentObject var virtualRobitBrain: RobitBrain

    @State var bag = Set<AnyCancellable>()
    @State var viewMode = ViewMode.joystick

    enum ViewMode: String, CaseIterable {
        case joystick
        case command
        case sequence
        case motion
        case virtualRobit
    }

    var body: some View {
        ZStack {
            SceneKitView(interactor: sceneKitInteractor)
            HStack {

                Spacer()
                VStack {
                    //                    BluetoothStatusView()
                    Picker(selection: $sceneKitInteractor.cameraPosition) {
                        ForEach(CameraPosition.allCases, id: \.self) { cameraPosition in
                            Text(cameraPosition.rawValue).tag(cameraPosition)
                        }
                    } label: {
                        Text("")
                    }.pickerStyle(SegmentedPickerStyle())
                    Text(robitState)

                    Picker(selection: $viewMode) {
                        ForEach(ViewMode.allCases, id: \.self) { mode in
                            Text(mode.rawValue).tag(mode)
                        }
                    } label: {
                        Text("")
                    }.pickerStyle(SegmentedPickerStyle())
                    Spacer()

                    switch viewMode {
                    case .joystick:
                        JoystickView(motorSpeed: $appState.sceneKitInteractor.virtualRobitBody.motorSpeed).frame(width: 420)
                    case .command:
                        CommandPanelView()
                    case .sequence:
                        SequenceControlView(sequenceController: appState.virtualRobitBrain.sequenceController)
                    case .motion:
                        MotionControlView(pidMotionControl: appState.virtualRobitBrain.motionController)
                    case .virtualRobit:
                        VirtualRobiPanelView()
                    }
                    Spacer()

                }.frame(width: 420)
            }
            MapDisplayView(mapController: appState.virtualRobitBrain.mapController, robitState: $appState.virtualRobitBrain.state).frame(width: 400, height: 400)
        }
    }
    
    var robitState: String {
        return "x:\(String(format: "%.2f", sceneKitInteractor.virtualRobitBody.state.position.x)), y: \(String(format: "%.2f", sceneKitInteractor.virtualRobitBody.state.position.y)), z:\(String(format: "%.2f", sceneKitInteractor.virtualRobitBody.state.position.z)),\n pitch:\(String(format: "%.2f", sceneKitInteractor.virtualRobitBody.state.orientation.x)), yaw: \(String(format: "%.2f", sceneKitInteractor.virtualRobitBody.state.orientation.y)), roll:\(String(format: "%.2f", sceneKitInteractor.virtualRobitBody.state.orientation.z))"
    }
}

#Preview {
    ControlView()
}
