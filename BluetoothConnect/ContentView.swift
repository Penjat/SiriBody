import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel: DevicesViewModel = .init()
    var body: some View {
        GeometryReader { geometry in
            VStack {
                Spacer()
                Circle().aspectRatio(1.0, contentMode: .fit)
                    .gesture(
                        DragGesture(minimumDistance: 0)
                            .onChanged { value in
                                let radius = (geometry.size.width/2)
                                let motor1Speed = max(-100,min(100,(value.location.y - radius)*100/radius))
                                let motor2Speed = max(-100,min(100,(value.location.y - radius)*100/radius))
                                print("Touch down \(motor1Speed) \(motor2Speed)")
                                
                                viewModel.motor1Speed = Int(motor1Speed < 0 ? abs(motor1Speed) : motor1Speed + 100)
                                viewModel.motor2Speed = Int(motor2Speed < 0 ? abs(motor2Speed) : motor2Speed + 100)
                            }
                            .onEnded { value in
                                viewModel.motor1Speed = 0
                                viewModel.motor2Speed = 0
                            }
                    )
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
