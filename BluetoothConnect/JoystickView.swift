import SwiftUI
import CoreMotion

struct JoystickView: View {
    @EnvironmentObject var viewModel: DevicesViewModel
    @State var touchPoint = CGPoint.zero
    // Create a CMMotionManager instance
//    let manager = CMMotionManager()
    @State var possitionData: CMDeviceMotion?
    @State var turnSensitivity = 1.0
    var body: some View {
        GeometryReader { geometry in
            
            VStack {
//                HStack {
//                    Text("\(possitionData?.attitude.pitch ?? 0)")
//                    Text("\(possitionData?.attitude.yaw ?? 0)")
//                    Text("\(possitionData?.attitude.roll ?? 0)")
//
//                }.font(.title3)
                Text("turn sensitivity: \(turnSensitivity)")
                Slider(value: $turnSensitivity, in: 0.0...1.0)
                HStack {
                    Text("\(viewModel.motorSpeed.motor1Speed)")
                    Spacer()
                    Text("\(viewModel.motorSpeed.motor2Speed)")
                }.font(.title3)
                Spacer()
                ZStack {
                    
                    Circle().aspectRatio(1.0, contentMode: .fit)
                        .gesture(
                            DragGesture(minimumDistance: 0)
                                .onEnded { value in
                                    viewModel.motorSpeed = (motor1Speed: 0, motor2Speed:  0)
                                    touchPoint = value.location
                                    viewModel.stopMotion()
                                }
                                .onChanged { value in
                                    
                                    let radius = (geometry.size.width/2)
                                    let forwardBackward = max(-100,min(100,(value.location.y - radius)*100/radius))
                                    let leftRight = max(-100*turnSensitivity,min(100*turnSensitivity,(value.location.x - radius)*100/radius))
                                    
                                    let motor1Speed = max(-100, min(100,(-forwardBackward + leftRight)))
                                    let motor2Speed = max(-100, min(100,(-forwardBackward - leftRight)))
                                    print("motor 1 \(motor1Speed) , motor 2 \(motor2Speed)")
                                    viewModel.motorSpeed = (motor1Speed: Int(motor1Speed), motor2Speed: Int(motor2Speed))
                                    touchPoint = value.location
                                }
                        )
                    Path { path in
                        if viewModel.motorSpeed.motor1Speed != 0, viewModel.motorSpeed.motor2Speed != 0 {
                            path.move(to: CGPoint(x: geometry.size.width/2, y: geometry.size.height/2))
                            path.addLine(to: CGPoint(x: touchPoint.x, y: touchPoint.y + geometry.size.width/2) )
                        }
                        
                    }.stroke(.blue, lineWidth: 6)
                }
                Spacer()
            }
        }
        .padding()
        .onAppear {
            viewModel.start()
            
            // Read the most recent accelerometer value
//            manager.accelerometerData?.acceleration.x
//            manager.accelerometerData?.acceleration.y
//            manager.accelerometerData?.acceleration.z
//
//            // How frequently to read accelerometer updates, in seconds
//            manager.accelerometerUpdateInterval = 0.1

            // Start accelerometer updates on a specific thread
//            manager.startDeviceMotionUpdates(to: OperationQueue.main) { (data, error) in
////                 Handle acceleration update
//                possitionData = data
//                
//            }
        }
    }
}

struct JoystickView_Previews: PreviewProvider {
    static var previews: some View {
        JoystickView()
    }
}
