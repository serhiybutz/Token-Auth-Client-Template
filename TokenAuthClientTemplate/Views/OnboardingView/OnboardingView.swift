import SwiftUI

struct OnboardingView: View {
    
    @StateObject var viewModel: OnboardingViewModel

    var body: some View {
        if viewModel.formKind == .signIn {
            viewModel.signInView()
        } else {
            viewModel.signUpView()
        }
    }
}
