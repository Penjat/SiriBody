import SwiftUI

struct ControlView: View {
    var body: some View {
        VStack {
            Text("Control View")
            BluetoothStatusView()
        }
        
    }
}

#Preview {
    ControlView()
}
