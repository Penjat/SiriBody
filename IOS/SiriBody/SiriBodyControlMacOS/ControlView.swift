import SwiftUI

struct ControlView: View {
    @EnvironmentObject var centralService: CentralService
    @State var message = ""
    @State var rotation = 0.0
    @State var x = ""
    @State var y = ""
    var body: some View {
        VStack {
            
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
}

#Preview {
    ControlView()
}
