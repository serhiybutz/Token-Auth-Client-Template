import Foundation

public struct RemoteUserSession: Codable, Equatable {
    // MARK: - Properties

    public let token: String

    // MARK: - Initializer

    public init(token: String) {

        self.token = token
    }
}
