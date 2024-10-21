import SwiftUI

struct TitleView: View {
    @EnvironmentObject var appState: AppState
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
                                        JoystickView(motorSpeed: $appState.movementInteractor.motorSpeed))
                        NavigationLink("Motion Status",
                                       destination: MotionStatusView())
                        NavigationLink("PID 🎚️🎚️🎚️",
                                       destination: RobitView())
                        NavigationLink("Reality Kit 👩🏻‍💻",
                                       destination:
                                        VStack {
//                            RealityKitStatusView()
                            MotionStatusView()
                        }
)
                        
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
