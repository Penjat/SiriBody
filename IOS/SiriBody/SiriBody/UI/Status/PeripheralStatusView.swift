import SwiftUI

struct PeripheralStatusView: View {
//    @EnvironmentObject var peripheralService: PeripheralService
    var body: some View {
        ZStack {
//            RoundedRectangle(cornerRadius: 16).fill(.ultraThickMaterial)
//            HStack {
//                switch peripheralService.connectionState {
//                case .advertising:
//                    ProgressView().progressViewStyle(CircularProgressViewStyle())
//                    Spacer()
//                    Text("Advertising...")
//                    Spacer()
//                    Button("stop", action: {
//                        peripheralService.peripheralManager?.stopAdvertising()
//                    })
//
//                case .connected(let central):
//                    Circle()
//                        .fill(.green)
//                        .frame(width: 20, height: 20)
//                    Spacer()
//                    Text("\(central.identifier)")
//                    Spacer()
//                case .disconnected:
//                    Circle()
//                        .fill(.gray)
//                        .frame(width: 20, height: 20)
//                    Spacer()
//                    Text("not connected")
//                    Spacer()
//                    Button("scan", action: {
//                        peripheralService.startAdvertising()
//                    })
//                }
//            }.padding()
        }.frame(height: 40)
    }
}
