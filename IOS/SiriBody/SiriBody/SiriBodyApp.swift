import SwiftUI

@main
struct SiriBodyApp: App {
    let appState = AppState()
    var body: some Scene {
        WindowGroup {
            TitleView()
                .environmentObject(appState)
                .environmentObject(appState.centralService)
                .environmentObject(appState.motionService)
//                .environmentObject(appState.locationService)
                .environmentObject(appState.goalInteractor)
                .environmentObject(appState.movementInteractor)
                .environmentObject(appState.robitStateService)
                .environmentObject(appState.peripheralService)
        }
    }
}
