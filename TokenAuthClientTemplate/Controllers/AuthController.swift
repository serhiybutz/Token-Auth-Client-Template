import Combine
import Foundation
import SwiftUI

protocol Authenticator {
    @MainActor
    var status: AuthStatus { get }
    @MainActor
    var userSession: UserSession? { get }
    func signIn(worker: @escaping () async throws -> UserSession) async
    func signOut() async
}

enum AuthStatus {

    case authenticated
    case nonAuthenticated
    case nonLoaded

    var isAuthenticated: Bool? {
        switch self {
        case .authenticated: return true
        case .nonAuthenticated: return false
        case .nonLoaded: return nil
        }
    }
}

actor AuthController: ObservableObject, Authenticator, Errorable {
    // MARK: - Properties

    let userSessionRepository: UserSessionRepository
    @Published @MainActor private(set) var status: AuthStatus = .nonLoaded
    @Published @MainActor var userSession: UserSession?
    nonisolated let errorPublisher = PassthroughSubject<Error, Never>()

    // MARK: - Initialization

    init(userSessionRepository: UserSessionRepository) {
        self.userSessionRepository = userSessionRepository
    }

    // MARK: - API

    func load(shouldAnimate: Bool = false) {

        Task {

            let session = await self.userSessionRepository.getUserSession()

            await MainActor.run {

                self.userSession = session

                // Update status:

                @MainActor func updateStatus() {
                    self.status = self.userSession?.isLoggedIn ?? false
                        ? .authenticated
                        : .nonAuthenticated
                }

                if shouldAnimate {
                    withAnimation { updateStatus() }
                } else {
                    updateStatus()
                }
            }
        }
    }

    func signIn(worker: @escaping () async throws -> UserSession) {

        Task {

            let userSession: UserSession
            do {

                userSession = try await Task.detached {
                    try await worker()
                }.value

                await MainActor.run {

                    self.userSession = userSession

                    withAnimation {
                        self.status = .authenticated
                    }
                }
            } catch {

                self.errorPublisher.send(error)
                return
            }
        }
    }

    func signOut() {

        Task {
            do {
                try await self.userSessionRepository.signOut()
            } catch {
                self.errorPublisher.send(error)
                return
            }
            self.load(shouldAnimate: true)
        }
    }
}
