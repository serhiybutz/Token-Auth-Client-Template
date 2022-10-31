import Foundation

struct ErrorResponse: Codable {
    // MARK: - Properties

    let error: Bool
    let reason: String
}
