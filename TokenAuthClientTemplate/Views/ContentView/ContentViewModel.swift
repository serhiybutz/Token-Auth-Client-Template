import Foundation
import SwiftUI

@MainActor
final class ContentViewModel: ObservableObject {
    // MARK: - Properties

    let onboardingView: () -> OnboardingView
    let homeView: () -> HomeView

    // MARK: - Initialization

    init(onboardingView: @escaping () -> OnboardingView,
         homeView: @escaping () -> HomeView) {
        self.onboardingView = onboardingView
        self.homeView = homeView
    }
}
