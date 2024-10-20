import SwiftUI
import Combine
import SceneKit

struct ControlView: View {
    @EnvironmentObject var centralService: CentralService
    @EnvironmentObject var robitPositionService: RobitPositionService
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var sceneKitInteractor: SceneKitInteractor
    @EnvironmentObject var virtualRobitInteractor: VirtualRobitInteractor
    @State var message = ""
    @State var rotation = 0.0
    @State var x = ""
    @State var y = ""
    @State var bag = Set<AnyCancellable>()
    
    var body: some View {
        VStack {
            SceneKitView(interactor: appState.sceneKitInteractor)

            HStack {
                JoystickView(motorSpeed: $virtualRobitInteractor.motorSpeed)
                VStack {
                    Text("reset")
                    HStack {
                        Button {
                            sceneKitInteractor.resetVirtualRobitPosition()
                        } label: {
                            Text("(0,0)")
                        }
                        Button {
                            sceneKitInteractor.resetVirtualRobitPosition(sceneKitInteractor.realRobit?.position ?? SCNVector3(x: 0, y: 0, z: 0), sceneKitInteractor.realRobit?.eulerAngles ?? SCNVector3(x: 0, y: 0, z: 0))
                        } label: {
                            Text("real robit")
                        }
                    }
                    Picker(selection: $sceneKitInteractor.cameraPosition) {
                        ForEach(CameraPosition.allCases, id: \.self) { cameraPosition in
                            Text(cameraPosition.rawValue).tag(cameraPosition)
                        }
                    } label: {
                        Text("camera")
                    }.pickerStyle(SegmentedPickerStyle())

                    Text(robitState)
                    BluetoothStatusView()
                    
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
                            centralService.outputSubject.send(Data(Command.moveTo(x: xDouble, z: yDouble).toData()))
                        }
                        
                    } label: {
                        Text("set target")
                    }
                    
                    Slider(value: $rotation, in: -Double.pi...Double.pi)
                    Button {
                        centralService.outputSubject.send(Data(Command.turnTo(angle: rotation).toData()))
                    } label: {
                        Text("set rotation")
                    }
                    
                    TextField("", text: $message)
                    Button(action: {
                        if let data = message.data(using: .utf8) {
                            centralService.outputSubject.send(data)
                        }
                    }, label: {
                        Text("send message")
                    })
                }
            }
            
        }.onAppear {
            //TODO: move this elsewhere
            centralService
                .inputSubject
                .throttle(for: .seconds(0.1), scheduler: RunLoop.main, latest: true).sink { data in
                    print("recieved state")
                    guard let state = StateData.createFrom(data: data) else {
                        return
                    }
                    
                    switch state {
                    case .positionOrientation(devicePosition: let position, deviceOrientation: let orientation):
                        //TODO: decide if I need this
//                        robitPositionService.robitPosition = RobitPosition(position: position, orientation: orientation)
                        appState.sceneKitInteractor.realRobitPosition = RobitPosition(position: position, orientation: orientation)
                    }
                }.store(in: &bag)
        }
    }
    var robitState: String {
        return "x:\(robitPositionService.robitPosition.position.x), y: \(robitPositionService.robitPosition.position.y), z:\(robitPositionService.robitPosition.position.z), pitch:\(robitPositionService.robitPosition.orientation.x), yaw: \(robitPositionService.robitPosition.orientation.y), roll:\(robitPositionService.robitPosition.orientation.z)"
    }
}

#Preview {
    ControlView()
}
