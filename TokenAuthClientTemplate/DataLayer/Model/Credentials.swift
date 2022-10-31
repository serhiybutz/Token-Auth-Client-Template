import Foundation

struct Credentials: Codable, Equatable {
    // MARK: - Properties

    let username: String
    let password: String

    // MARK: - Initialization
    
    init?(username: String, password: String) {
        let username = username.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !username.isEmpty else { return nil }
        let password = password.trimmingCharacters(in: .whitespacesAndNewlines)
        self.username = username
        self.password = password
    }
}
