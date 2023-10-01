import SwiftUI

@main
struct BluetoothServiceApp: App {
        @StateObject var appState = AppState()
    var body: some Scene {
        WindowGroup {
            ContentView().environmentObject(appState)
        }
    }
}
