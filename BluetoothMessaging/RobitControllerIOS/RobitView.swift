import SwiftUI

struct RobitView: View {
    @StateObject var viewModel = RobitViewModel()
    var body: some View {
        Text("Robit")
        TextField("message", text: $viewModel.messageText)
        Button("Send") {
            self.viewModel.peripheralService.dataOUT.send(self.viewModel.messageText.data(using: .utf8)!)
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
