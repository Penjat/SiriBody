import SwiftUI

struct PeripheralStatusView: View {
    @EnvironmentObject var appState: AppState
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 16).fill(.ultraThickMaterial)
            HStack {
                switch appState.peripheralService.connectionStateSubject.value {
                case .advertising:
                    ProgressView().progressViewStyle(CircularProgressViewStyle())
                    Spacer()
                    Text("Advertising...")
                    Spacer()
                    Button("stop", action: {
                        appState.peripheralService.peripheralManager?.stopAdvertising()
                    })

                case .connected(let central):
                    Circle()
                        .fill(.green)
                        .frame(width: 20, height: 20)
                    Spacer()
                    Text("\(central.identifier)")
                    Spacer()
                case .disconnected:
                    Circle()
                        .fill(.gray)
                        .frame(width: 20, height: 20)
                    Spacer()
                    Text("not connected")
                    Spacer()
                    Button("scan", action: {
                        appState.peripheralService.startAdvertising()
                    })
                }
            }.padding()
        }.frame(height: 40)
    }
}
