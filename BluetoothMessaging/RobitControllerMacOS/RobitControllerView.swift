import SwiftUI

struct RobitControllerView: View {
    @StateObject var viewModel = RobitControllerViewModel()
    
    var body: some View {
        VStack {
            TextField("message", text: $viewModel.messageText)
            Button("send msg") {
                if let transferCharacteristic = viewModel.centralService.transferCharacteristic {
                    viewModel.centralService.discoveredPeripheral?.writeValue(viewModel.messageText.data(using: .utf8)!, for: transferCharacteristic, type: .withoutResponse)
                }
            }
            ForEach(viewModel.recievedData, id: \.self) { text in
                Text(text).foregroundColor(.white)
            }
        }
        .frame(width: 500, height: 500)
    }
}

struct RobitControllerView_Previews: PreviewProvider {
    static var previews: some View {
        RobitControllerView()
    }
}
