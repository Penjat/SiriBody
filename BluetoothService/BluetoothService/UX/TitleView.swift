import SwiftUI

struct TitleView: View {
    @EnvironmentObject var appState: AppState
    var body: some View {
        NavigationView {
            VStack {
                NavigationLink("Glove Synth", destination:
                                GloveSynthView(viewModel: gloveSynthViewModel))
                NavigationLink("Synth Test", destination:
                                GloveStatusView(viewModel: gloveStatusViewModel))
            }
        }
    }

    var gloveSynthViewModel: GloveSynthViewModel {
        GloveSynthViewModel(
            synth: appState.synth,
            gloveService: appState.gloveDataService)
    }

    var gloveStatusViewModel: GloveStatusViewModel {
        GloveStatusViewModel(gloveService: appState.gloveDataService)
    }
}

struct TitleView_Previews: PreviewProvider {
    static var previews: some View {
        TitleView()
    }
}
