import Combine
import Foundation
import SwiftUI
import OSLog

@MainActor
final class SignInViewModel: ObservableObject, Errorable {
    // MARK: - Properties

    let userSessionRepository: UserSessionRepository
    let moveToSignUp: () -> Void

    let authenticator: Authenticator

    @Published var username: String = ""
    @Published var password: String = ""

    nonisolated let errorPublisher = PassthroughSubject<Error, Never>()

    // MARK: - Initialization

    init(userSessionRepository: UserSessionRepository, authenticator: Authenticator, moveToSignUp: @escaping () -> Void) {

        self.userSessionRepository = userSessionRepository
        self.authenticator = authenticator
        self.moveToSignUp = moveToSignUp
    }

    // MARK: - API
    
    func signIn(_ submitButtonReportable: AnimSubmitButtonReportable) async {

        await authenticator.signIn {
            try await self.userSessionRepository.signIn(
                username: self.username,
                password: self.password
            )
        }

        if authenticator.status.isAuthenticated ?? false {
            submitButtonReportable.signalActionSuccess()
        } else {
            submitButtonReportable.signalActionFailure()
        }
    }

    func fillCredentialsFromUserSession(_ exec: @escaping () -> Void) {

        Task {
            if let userSession = await userSessionRepository.getUserSession() {
                self.username = userSession.credentials.username
                self.password = userSession.credentials.password
                exec()
            } else {
                os_log(.info, log: OSLog.default, "[SignInViewModel] Attempt to use user credentials from a non-existing user session.")
            }
        }
    }
}
