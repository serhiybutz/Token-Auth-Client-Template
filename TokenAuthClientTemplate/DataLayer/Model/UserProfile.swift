import Foundation

struct UserProfile: Equatable, Codable {
    // MARK: - Properties

    let fullname: String
    let email: String?
    let phone: String?
    let avatar: URL?
}
