import SwiftUI
import Combine

struct PIDControlView: View {
    @ObservedObject var viewModel = ViewModel()
    @StateObject var robitModel = RobitModel()
    @StateObject var pidContoller = PIDController()

    @State var bag = Set<AnyCancellable>()

    var body: some View {
        VStack {
            ZStack {
                Circle()
                Rectangle()
                    .fill(.green)
                    .frame(width: 20, height: 150)
                    .offset(CGSize(width: 0, height: -100))
                    .rotationEffect(Angle(degrees: robitModel.rotation))
                Rectangle()
                    .fill(.red)
                    .frame(width: 20, height: 20)
                    .offset(CGSize(width: 0, height: -160))
                    .rotationEffect(Angle(degrees: pidContoller.goal))
            }



            VStack {
                Picker("PID control", selection: $viewModel.controlMode) {
                    ForEach(ControlMode.allCases, id: \.self) { mode in
                        Text(mode.rawValue)
                    }
                }.pickerStyle(SegmentedPickerStyle())

                switch viewModel.controlMode {
                case .pid:
                    pidControls
                case .robit:
                    robitControls
                case .user:
                    userControls
                }
            }
            .padding()
            .border(.black, width: /*@START_MENU_TOKEN@*/1/*@END_MENU_TOKEN@*/)
            .padding()
        }
        .onAppear {
            robitModel.statePublisher
                .sink { robitState in
                    if viewModel.pidControlOn {
                        let throttleAmt = pidContoller.processInput(.init(rotation: robitState.rotation, deltaTime: robitState.deltaTime))
                        robitModel.setThrottle(throttleAmt)
                    }
                }.store(in: &bag)
        }
    }

    var pidControls: some View {
        return Group {
            Spacer()

            Toggle("PID control on", isOn: $viewModel.pidControlOn)
            Text("P: \(pidContoller.pValue)")
            HStack {
                Toggle("", isOn: $pidContoller.pIsOn)
                Slider(value: $pidContoller.pValue, in: 0.0...5).disabled(!pidContoller.pIsOn)
            }
            Text("I: \(pidContoller.iValue)")
            HStack {

                Toggle("", isOn: $pidContoller.iIsOn)
                Slider(value: $pidContoller.iValue, in: 0.00001...0.01).disabled(!pidContoller.iIsOn)
            }
            Text("D: \(pidContoller.dValue)")
            HStack {

                Toggle("", isOn: $pidContoller.dIsOn)
                Slider(value: $pidContoller.dValue, in: 0.0...5).disabled(!pidContoller.dIsOn)
            }
            Spacer()
        }
    }

    var userControls: some View {
        return Group {
            Spacer()
            Text("\(String(format: "%.2f", robitModel.throttleAmt))")
            Slider(value: $robitModel.throttleAmt, in: RobitModel.Constants.accelerationRange).tint(.gray)
            Spacer()
        }
    }

    var robitControls: some View {
        return VStack {
            Text("Acceleration:")
            HStack {

                Slider(value: $robitModel.acceleration, in: 0.0001...0.01)
            }
            Text("Friction:")
            HStack {

                Slider(value: $robitModel.friction, in: 0.9...0.99)
            }
            Text("Max Velocity:")
            HStack {

                Slider(value: $robitModel.maxVelocity, in: 0.1...4)
            }
            Spacer()
        }
    }
}

#Preview {
    PIDControlView(viewModel: PIDControlView.ViewModel(), robitModel: RobitModel())
}
