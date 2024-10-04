import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel: DevicesViewModel = .init()
    @State var touchPoint = CGPoint.zero
    var body: some View {
        TabView {
            JoystickView().tabItem {
                Image(systemName: "gamecontroller")
            }
            CommandsView().tabItem {
                Image(systemName: "scroll.fill")
            }
        }.environmentObject(viewModel)
    }
}
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
