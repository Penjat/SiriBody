import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel: DevicesViewModel = .init()
    var body: some View {
        
            VStack(spacing: 40){
                HStack {
                    Text("\(viewModel.motor1Speed)")
                    Spacer()
                    Text("\(viewModel.motor2Speed)")
                }
                Spacer()
                HStack {
                    Rectangle()
                        .fill(.blue)
                        .frame(width: 150, height: 500)
                        .padding()
                        .gesture(
                            DragGesture(minimumDistance: 0)
                                .onChanged { value in
                                    print("Touch down \(value.location.y)")
                                    let speed = Int(250 - value.location.y)*100/255
                                    viewModel.motor1Speed = speed < 0 ? abs(speed) : speed + 100
                                }
                                .onEnded { value in
                                    print("released")
                                    viewModel.motor1Speed = 0
                                }
                        )
                    
                    Rectangle()
                        .fill(.blue)
                        .frame(width: 150, height: 500)
                        .padding()
                        .gesture(
                            DragGesture(minimumDistance: 0)
                                .onChanged { value in
                                    print("Touch down \(value.location.y)")
                                    let speed = Int(250 - value.location.y)*100/255
                                    viewModel.motor2Speed = speed < 0 ? abs(speed) : speed + 100
                                }
                                .onEnded { value in
                                    print("released")
                                    viewModel.motor2Speed = 0
                                }
                        )
                }
                
                Spacer()
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
