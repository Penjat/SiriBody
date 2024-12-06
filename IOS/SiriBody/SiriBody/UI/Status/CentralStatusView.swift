import SwiftUI

struct CentralStatusView: View {
    @EnvironmentObject var appState: AppState

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 16).fill(.ultraThickMaterial)
            HStack {
                switch appState.centralService.connectionStateSubject.value {
                case .scanning:
                    ProgressView().progressViewStyle(CircularProgressViewStyle())
                    Spacer()
                    Text("Scanning for devices...")
                    Spacer()
                    Button("stop", action: {
                        appState.centralService.stopScanning()
                    })
                    
                case .connected(let peripheral):
                    Circle()
                        .fill(.green)
                        .frame(width: 20, height: 20)
                    Spacer()
                    Text("\(peripheral.name ?? "")")
                    Spacer()
                case .disconnected:
                    Circle()
                        .fill(.gray)
                        .frame(width: 20, height: 20)
                    Spacer()
                    Text("not connected")
                    Spacer()
                    Button("scan", action: {
                        appState.centralService.retrievePeripheral()
                    })
                }
            }.padding()
        }.frame(height: 40)
    }
}

