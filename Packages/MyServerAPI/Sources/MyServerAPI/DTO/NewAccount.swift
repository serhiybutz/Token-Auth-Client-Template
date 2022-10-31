import Foundation

public struct NewAccount: Codable, Equatable {
    // MARK: - Properties

    public let fullname: String
    public let username: String
    public let email: String
    public let phone: String
    public let password: String

    // MARK: - Initializer

    public init(fullname: String, username: String, email: String, phone: String, password: String) {
        
        self.fullname = fullname
        self.username = username
        self.email = email
        self.phone = phone
        self.password = password
    }
}
