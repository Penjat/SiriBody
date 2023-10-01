import SwiftUI

struct GloveSynthView: View {
    @StateObject var viewModel: GloveSynthViewModel
    var body: some View {
        ZStack {
            VStack {
                Spacer()
                PowerGloveStatusView(gloveState: gloveState).opacity(isConnected ? 1.0 : 0.6)

            }

            if !isConnected {
                Text("Not connected...")
            }
        }
    }

    var isConnected: Bool {
        viewModel.gloveState != nil
    }

    var gloveState: PowerGloveDataObject {
        return viewModel.gloveState ?? defaultGloveState
    }

    var defaultGloveState: PowerGloveDataObject {
        PowerGloveDataObject(
            fingerSensor1: 255,
            fingerSensor2: 255,
            fingerSensor3: 255,
            button1State: false,
            button2State: false,
            button3State: false,
            gyroX: 0,
            gyroY: 0,
            gyroZ: 0,
            accelX: 0,
            accelY: 0,
            accelZ: 0)
    }
}

//struct GloveSynthView_Previews: PreviewProvider {
//    static var previews: some View {
//        GloveSynthView()
//    }
//}
