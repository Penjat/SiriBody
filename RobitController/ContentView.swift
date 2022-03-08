import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel: DevicesViewModel = .init()
    @State var touchPoint = CGPoint.zero
    var body: some View {
        GeometryReader { geometry in
            
            VStack {
                HStack {
                    Text("\(viewModel.motor1Speed)")
                    Spacer()
                    Text("\(viewModel.motor2Speed)")
                }.font(.title3)
                Spacer()
                ZStack {
                    
                    Circle().aspectRatio(1.0, contentMode: .fit)
                        .gesture(
                            DragGesture(minimumDistance: 0)
                                .onChanged { value in
                                    let radius = (geometry.size.width/2)
                                    let forwardBackward = max(-100,min(100,(value.location.y - radius)*100/radius))
                                    let leftRight = max(-100,min(100,(value.location.x - radius)*100/radius))
                                    
                                    let motor1Speed = max(-100,min(100,(forwardBackward + leftRight)))
                                    let motor2Speed = max(-100,min(100,(forwardBackward - leftRight)))
                                    print("Touch down \(motor1Speed) \(motor2Speed)")
                                    
                                    viewModel.motor1Speed = Int(motor1Speed < 0 ? abs(motor1Speed) : motor1Speed + 100)
                                    viewModel.motor2Speed = Int(motor2Speed < 0 ? abs(motor2Speed) : motor2Speed + 100)
                                    touchPoint = value.location
                                }
                                .onEnded { value in
                                    viewModel.motor1Speed = 0
                                    viewModel.motor2Speed = 0
                                    touchPoint = value.location
                                }
                        )
                    Path { path in
                        if viewModel.motor1Speed != 0, viewModel.motor2Speed != 0 {
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
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
