import SwiftUI
import Combine
import SceneKit

struct ControlView: View {
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var sceneKitInteractor: SceneKitInteractor
//    @EnvironmentObject var virtualRobitInterface: VirtualRobitInterface

    @State var bag = Set<AnyCancellable>()
    
    var body: some View {
        VStack {
            SceneKitView(interactor: sceneKitInteractor)

            HStack {
                JoystickView(motorSpeed: $appState.sceneKitInteractor.virtualRobit.motorSpeed).frame(width: 420)
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


//                    Text(robitState)
                    BluetoothStatusView()
                }.frame(width: 420)
            }
            
        }
    }
//    var robitState: String {
//        return "x:\(appState.realRobitState?.position.x), y: \(appState.realRobitState?.position.y), z:\(appState.realRobitState?.position.z), pitch:\(appState.realRobitState?.position.x), yaw: \(appState.realRobitState?.position.y), roll:\(appState.realRobitState?.position.z)"
//    }
}

#Preview {
    ControlView()
}
