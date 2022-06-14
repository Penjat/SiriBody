import SwiftUI

struct BluetoothStateView: View {
    @EnvironmentObject var viewModel: DevicesViewModel
    var body: some View {
        VStack {
            if let body = viewModel.connectedBody {
                Text("Connected")
            } else {
                Text("Not Connected")
            }
        }
    }
}
