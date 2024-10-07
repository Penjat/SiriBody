import SwiftUI

struct LocationStatusView: View {
    @EnvironmentObject var locationsService: LocationService
    var body: some View {
        VStack {
            Text("speed: \(locationsService.location?.speed)")
            Text("speed: \(locationsService.location?.coordinate)")
            Text("speed: \(locationsService.location?.course)")

        }
    }
}

#Preview {
    LocationStatusView()
}
