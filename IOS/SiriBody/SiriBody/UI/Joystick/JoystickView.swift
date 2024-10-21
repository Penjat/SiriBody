import SwiftUI

struct JoystickView: View {
    @Binding var motorSpeed: MotorOutput
    @State var touchPoint: CGPoint?
    @State var turnSensitivity = 1.0
    @State var speedDamping = 1.0
    var body: some View {
        
        VStack {
            
            Text("turn sensitivity: \(turnSensitivity)")
            Slider(value: $turnSensitivity, in: 0.0...1.0)
            Text("speed damping: \(Int(100 - speedDamping*100))%")
            Slider(value: $speedDamping, in: 0.2...1.0)
            HStack {
                Text("\(motorSpeed.motor1)")
                Spacer()
                Text("\(motorSpeed.motor2)")
            }.font(.title3)
            Spacer()
            GeometryReader { geometry in
                ZStack {
                    
                    Circle().aspectRatio(1.0, contentMode: .fit)
                        .gesture(
                            DragGesture(minimumDistance: 0)
                                .onEnded { value in
                                    motorSpeed = MotorOutput.zero
                                    touchPoint = nil
                                }
                                .onChanged { value in
                                    
                                    let radius = (geometry.size.width/2)
                                    let forwardBackward = max(-254,min(254,(value.location.y - radius)*254/radius))
                                    let leftRight = max(-254*turnSensitivity,min(254*turnSensitivity,(value.location.x - radius)*254/radius))
                                    
                                    let motor1Speed = max(-254,min(254,(forwardBackward + leftRight)))*(-1)*speedDamping
                                    let motor2Speed = max(-254,min(254,(forwardBackward - leftRight)))*(-1)*speedDamping
                                    
                                    motorSpeed = MotorOutput(motor1: Int(motor1Speed), motor2: Int(motor2Speed))
                                    touchPoint = value.location
                                }
                        )
                    Path { path in
                        if let touchPoint {
                            path.move(to: CGPoint(x: geometry.size.width/2, y: geometry.size.height/2))
                            path.addLine(to: CGPoint(x: touchPoint.x, y: touchPoint.y) )
                            
                        }
                    }.stroke(.blue, lineWidth: 6)
                }
            }.frame(width:400, height: 400)
        }
        .padding()
    }
}
