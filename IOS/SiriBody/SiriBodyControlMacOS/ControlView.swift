import SwiftUI

struct ControlView: View {
    @EnvironmentObject var centralService: CentralService
    @State var message = ""
    @State var rotation = 0.0
    var body: some View {
        VStack {
            
            BluetoothStatusView()
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
}

#Preview {
    ControlView()
}
