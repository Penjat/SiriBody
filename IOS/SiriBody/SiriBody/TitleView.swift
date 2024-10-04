import SwiftUI

struct TitleView: View {
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var movementInteractor: MovementInteractor
    var body: some View {
        NavigationView {
            VStack {
                Spacer()
                HStack {
                    VStack(alignment: .trailing, spacing: 20) {
                        Text("Siri Body")
                            .bold()
                            .font(.largeTitle)
                        Spacer().frame(height: 40)
                        NavigationLink("Joystick 🕹️",
                                       destination:
                                        JoystickView(motorSpeed: $movementInteractor.motorSpeed))
                        NavigationLink("Robit 🤖",
                                       destination:
                                        JoystickView(motorSpeed: $movementInteractor.motorSpeed))
                        NavigationLink("Virtual 👩🏻‍💻",
                                       destination:
                                        JoystickView(motorSpeed: $movementInteractor.motorSpeed))
                        
                    }.font(.title)
                    Rectangle()
                        .fill(.purple)
                        .opacity(0.4)
                        .frame(width: 20)
                }
                Spacer()
            }
        }
    }
}

#Preview {
    TitleView()
}
