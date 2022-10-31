import Foundation

public struct UserProfile: Codable, Equatable {
    // MARK: - Properties


    public let fullname: String
    public let email: String?
    public let phone: String?
    public let avatar: URL?

    // MARK: - Initializer

    public init(fullname: String, email: String? = nil, phone: String? = nil, avatar: URL? = nil) {
        
        self.fullname = fullname
        self.email = email
        self.phone = phone
        self.avatar = avatar
    }
}
