import Foundation

public struct Credentials: Codable, Equatable {
    // MARK: - Properties

    public let username: String
    public let password: String

    // MARK: - Initializer

    public init?(username: String, password: String) {
        let username = username.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !username.isEmpty else { return nil }
        let password = password.trimmingCharacters(in: .whitespacesAndNewlines)
        self.username = username
        self.password = password
    }
}
