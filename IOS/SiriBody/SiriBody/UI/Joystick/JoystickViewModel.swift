import Combine

class JoystickViewModel: ObservableObject {
    @Published var motorSpeed = (motor1Speed: 0, motor2Speed: 0)
}
