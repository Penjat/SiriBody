import SwiftUI

struct BodyInputView: View {
    @EnvironmentObject var viewModel: BodyViewModel
    var body: some View {
        VStack {
            switch viewModel.selectedInput {
            case .BluetoothController:
                Text("Bluetooth")
            case .Mock:
                Text("Mock")
            }
        }
        .frame(height: 200)
        .frame(maxWidth: .infinity)
        .border(Color.blue, width: 4)
        .cornerRadius(8.0)
    }
}

struct BodyInputView_Previews: PreviewProvider {
    static var previews: some View {
        BodyInputView()
    }
}
