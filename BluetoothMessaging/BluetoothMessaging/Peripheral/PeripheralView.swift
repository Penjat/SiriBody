import SwiftUI
import CoreBluetooth
import Combine

struct PeripheralView: View {
    @StateObject var viewModel = PeripheralViewModel()
    
    var body: some View {
        VStack(spacing: 30) {
            Toggle(isOn: $viewModel.isAdvertising) {
                Text("advertising")
                
                TextField("Message text", text: $viewModel.text)
                
                Button("send message") {
                    viewModel.sendMessage()
                }
            }
        }
    }
}

struct PeripheralView_Previews: PreviewProvider {
    static var previews: some View {
        PeripheralView()
    }
}
