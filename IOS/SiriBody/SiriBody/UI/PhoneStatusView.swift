import SwiftUI

struct PhoneStatusView: View {
    var body: some View {
        VStack {
            MotionStatusView()
            LocationStatusView()
        }
    }
}

#Preview {
    PhoneStatusView()
}
