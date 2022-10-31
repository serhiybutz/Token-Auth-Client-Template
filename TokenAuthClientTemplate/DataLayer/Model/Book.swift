import Foundation

struct Book: Decodable, Identifiable {
    // MARK: - Properties

    let id: UUID
    let title: String
    let author: String
    let genres: [Genre]
}
