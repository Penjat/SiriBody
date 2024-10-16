import SwiftUI
import Combine

struct ControlView: View {
    @EnvironmentObject var centralService: CentralService
    @State var message = ""
    @State var rotation = 0.0
    @State var x = ""
    @State var y = ""
    @State var bag = Set<AnyCancellable>()
    @State var robitState = "no data"
    var body: some View {
        VStack {
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
            SceneKitView()
        }.onAppear {
            centralService
                .inputSubject
                .throttle(for: .seconds(0.1), scheduler: RunLoop.main, latest: true).sink { data in
                    print("recieved state")
                    guard let state = StateData.createFrom(data: data) else {
                        return
                        }

                    switch state {
                    case .positionOrientation(devicePosition: let position, deviceOrientation: let orientation):
                        robitState = "x:\(position.x), y: \(position.y), z:\(position.z), pitch:\(orientation.x), yaw: \(orientation.y), roll:\(orientation.z)"
                    }
            }.store(in: &bag)
        }
    }
}

#Preview {
    ControlView()
}
