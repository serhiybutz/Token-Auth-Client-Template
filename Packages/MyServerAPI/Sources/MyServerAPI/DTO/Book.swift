import Foundation

public struct Book: Codable, Equatable {
    // MARK: - Properties

    public let id: UUID
    public let title: String
    public let author: String
    public let genres: [Genre]
}
