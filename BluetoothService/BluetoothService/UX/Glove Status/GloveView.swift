import SwiftUI
import CoreBluetooth

struct GloveView: View {
    @StateObject var viewModel: GloveViewModel
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
            fingerSensor1: 0,
            fingerSensor2: 0,
            fingerSensor3: 0,
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

//struct GloveView_Previews: PreviewProvider {
//
//    static var previews: some View {
//        GloveView()
//        GloveView(viewModel: viewModel)
//    }
//
//    static var viewModel: GloveViewModel {
//        let model = GloveViewModel()
//        model.gloveState = PowerGloveDataObject(fingerSensor1: 222, fingerSensor2: 33, fingerSensor3: 120, button1State: false, button2State: true, button3State: false, gyroX: 100, gyroY: 19, gyroZ: 56, accelX: 10, accelY: 20, accelZ: 5)
//        return model
//    }
//}
