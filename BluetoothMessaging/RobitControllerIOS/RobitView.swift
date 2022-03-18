import SwiftUI

struct RobitView: View {
    @StateObject var viewModel = RobitViewModel()
    var body: some View {
        Text("Robit")
        TextField("message", text: $viewModel.messageText)
        Button("Send") {
            if let transferCharacteristic = viewModel.peripheralService.transferCharacteristic {
                viewModel.peripheralService.peripheralManager.updateValue(viewModel.messageText.data(using: .utf8)!, for: transferCharacteristic, onSubscribedCentrals: nil)
            }
        }
        ForEach(viewModel.reciededData, id: \.self) { text in
            Text(text)
        }
    }
}

struct RobitView_Previews: PreviewProvider {
    static var previews: some View {
        RobitView()
    }
}
