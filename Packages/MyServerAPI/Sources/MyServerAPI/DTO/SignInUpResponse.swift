import Foundation

struct SignInUpResponse: Codable {
    // MARK: - Properties

    let profile: UserProfile
    let token: String
}
