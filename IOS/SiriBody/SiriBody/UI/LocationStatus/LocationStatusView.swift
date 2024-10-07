import SwiftUI

struct LocationStatusView: View {
    @EnvironmentObject var locationsService: LocationService
    var body: some View {
        VStack {
            Text("latitude: \(locationsService.location?.coordinate.latitude)")
            Text("longitude: \(locationsService.location?.coordinate.longitude)")
            
 
        }
    }
}

#Preview {
    LocationStatusView()
}
