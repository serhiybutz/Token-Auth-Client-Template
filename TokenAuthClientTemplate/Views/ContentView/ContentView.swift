import SwiftUI

struct ContentView: View {

    @StateObject var viewModel: ContentViewModel
    @StateObject var authController: AuthController
    @StateObject var errorPresenterViewModel: ErrorPresenterViewModel

    var body: some View {
        
        Group {
            if let isAuthenticated = authController.status.isAuthenticated {
                if isAuthenticated {

                    viewModel.homeView()
                        .transition(.slide)
                } else {

                    viewModel.onboardingView()
                        .transition(.slide)
                }
            }
        }
        .errorPresenter(viewModel: errorPresenterViewModel)
        .task {

            await authController.load()
        }
    }
}
