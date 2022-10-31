import Foundation
import SwiftUI

@MainActor
final class OnboardingViewModel: ObservableObject {
    // MARK: - Properties

    @Published var formKind: FormKind = .signIn

    var signInView: (() -> SignInView)!
    var signUpView: (() -> SignUpView)!

    @Published var isLoginDisabled: Bool = false

    // MARK - Types

    enum FormKind { case signIn, signUp }
}
