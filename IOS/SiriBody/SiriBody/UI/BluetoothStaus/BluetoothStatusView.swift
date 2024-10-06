import SwiftUI

struct BluetoothStatusView: View {
    @EnvironmentObject var centralService: CentralService
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 16).fill(.ultraThickMaterial)
            HStack {
                switch centralService.connectionState {
                case .scanning:
                    ProgressView().progressViewStyle(CircularProgressViewStyle())
                    
                    Text("Scanning for devices...")
                    Spacer()
                    Button("stop scanning", action: {
                        centralService.stopScanning()
                    })
                case .connected:
                    Circle()
                        .fill(.green)
                        .frame(width: 20, height: 20)
                    Text("connected")
                    Spacer()
                case .disconnected:
                    Circle()
                        .fill(.gray)
                        .frame(width: 20, height: 20)
                    Text("not connected")
                    Spacer()
                    Button("Start Scanning", action: {
                        centralService.retrievePeripheral()
                    })
                }
            }.padding()
        }.frame(height: 40)
    }
}

