import SwiftUI

struct BodyOutputView: View {
    @EnvironmentObject var viewModel: BodyViewModel
    var body: some View {
        VStack {
            switch viewModel.selectedOutput {
            case .BlueTooth:
                Text("Bluetooth Output")
            case .Mock:
                Text("Mock")
            }
        }
        .frame(height: 400)
        .frame(maxWidth: .infinity)
        .border(Color.blue, width: 4)
            .cornerRadius(8.0)
    }
}

struct BodyOuputView_Previews: PreviewProvider {
    static var previews: some View {
        BodyOutputView()
    }
}
