import SwiftUI
import Combine

struct RobitView: View {
    @EnvironmentObject var appState: AppState

    @State var motionEnabled = false
    @State var bag = Set<AnyCancellable>()
    
    var body: some View {
        VStack {
            Text("Robit View")
            PeripheralStatusView()
            CentralStatusView()
            
        }
    }
}

#Preview {
    RobitView()
}
