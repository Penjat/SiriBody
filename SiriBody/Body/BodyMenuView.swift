import SwiftUI

enum BodyOutput: String, CaseIterable {
    case BlueTooth
    case Mock
}

enum BodyInput: String, CaseIterable {
    case BluetoothController
    case Mock
}

struct BodyMenuView: View {
    @EnvironmentObject var viewModel: BodyViewModel
    var body: some View {
        VStack {
            Picker(selection: $viewModel.selectedInput) {
                ForEach(BodyInput.allCases, id: \.rawValue) { outputType in
                    Text(outputType.rawValue).tag(outputType)
                }
            } label: {
                Text("Output select")
            }.pickerStyle(SegmentedPickerStyle())
            
            switch viewModel.selectedInput {
            case .Mock:
                Text("Mock Body")
            case .BluetoothController:
                Text("Blue tooth")
            }
            
            Spacer()
            Picker(selection: $viewModel.selectedOutput) {
                ForEach(BodyOutput.allCases, id: \.rawValue) { outputType in
                    Text(outputType.rawValue).tag(outputType)
                }
            } label: {
                Text("Output select")
            }.pickerStyle(SegmentedPickerStyle())
            
            switch viewModel.selectedOutput {
            case .Mock:
                Text("Mock Body")
            case .BlueTooth:
                Text("Blue tooth")
            }
            
            
        }
        .padding()
    }
}

struct BodyMenuView_Previews: PreviewProvider {
    static var previews: some View {
        BodyMenuView()
    }
}
