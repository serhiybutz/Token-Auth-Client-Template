import Foundation

struct RemoteUserSession: Codable, Equatable {
    // MARK: - Properties

    let token: AuthToken

    // MARK: - Initialization

    init(token: AuthToken) {

        self.token = token
    }
}
