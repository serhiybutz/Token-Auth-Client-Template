import Foundation

struct NewAccount: Codable {
    // MARK: - Properties

    let fullname: String
    let username: String
    let password: Secret
    let email: String
    let phone: String
}
