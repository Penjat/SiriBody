import SwiftUI
import Combine

struct RobitView: View {
    @EnvironmentObject var motionService: MotionService
    @EnvironmentObject var movementInteractor: MovementInteractor
    
    @StateObject var pidControl = PIDRotationControl()
    
    @State var motionEnabled = false
    @State var bag = Set<AnyCancellable>()
    
    var body: some View {
        VStack {
            Spacer()
            Text("goal: \(String(format: "%.2f", pidControl.targetYaw))")
            Button(action: {
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    pidControl.targetYaw = Double.random(in: -Double.pi..<Double.pi)
                    }
                
            }, label: {
                Text("New Goal")
            })
            Text("Yaw")
            ZStack {

                Circle()
                    .trim(from: 0, to: CGFloat(((pidControl.targetYaw) + .pi) / (2 * .pi)))
                    .stroke(Color.orange, lineWidth: 20)
                    .frame(width: 80, height: 80)
                    .rotationEffect(.degrees(-90))
                
                Circle()
                    .trim(from: 0, to: CGFloat(((motionService.position?.attitude.yaw ?? 0) + .pi) / (2 * .pi)))
                    .stroke(Color.green, lineWidth: 10)
                    .frame(width: 80, height: 80)
                    .rotationEffect(.degrees(-90))
                    .overlay(Text("\(String(format: "%.2f", motionService.position?.attitude.yaw ?? 0.0))"))
            }
            
            Toggle(isOn: $motionEnabled) {
                Text("Motion Enabled")
            }
            
            Spacer()
            Text("Max Speed: \(pidControl.maxSpeed)")
            Slider(value: $pidControl.maxSpeed, in: 50.0...254.0)
            
            
            HStack {
                VStack {
                    Toggle("", isOn: $pidControl.pIsOn)
                    Text("\(String(format: "%.2f", pidControl.pConstant))")
                    Text("\(String(format: "%.2f", pidControl.pOutput))").monospaced()
                    Slider(value: $pidControl.pConstant, in: 0.5...200).disabled(!pidControl.pIsOn)
                }
                
                
                
                
                VStack {
                    Toggle("", isOn: $pidControl.iIsOn)
                    Text("\(String(format: "%.2f", pidControl.iConstant))")
                    Text("\(String(format: "%.2f", pidControl.iOutput))").monospaced()
                    Slider(value: $pidControl.iConstant, in: 0.01...200).disabled(!pidControl.iIsOn)
                }
                
                VStack {
                    Toggle("", isOn: $pidControl.dIsOn)
                    Text("\(String(format: "%.2f", pidControl.dConstant))")
                    Text("\(String(format: "%.2f", pidControl.dOutput))").monospaced()
                    Slider(value: $pidControl.dConstant, in: 0.5...200).disabled(!pidControl.dIsOn)
                }
                
            }.padding()
            
            
            BluetoothStatusView()
            
        }.onAppear {
            motionService.$position.sink { deviceMotion in
                let turnVector = pidControl.motorOutput(currentYaw: deviceMotion?.attitude.yaw ?? 0.0)
                print(turnVector)
                
                
                let forwardBackward = 0.0
                let leftRight = max(-254,min(254,(turnVector)))
                
                let motor1Speed = max(-254,min(254,(forwardBackward - leftRight)))*(-1)
                let motor2Speed = max(-254,min(254,(forwardBackward + leftRight)))*(-1)
                
                if motionEnabled {
                    movementInteractor.motorSpeed = (motor1Speed: Int(motor1Speed), motor2Speed: Int(motor2Speed))
                }
            }.store(in: &bag)
        }
    }
}

#Preview {
    RobitView()
}
