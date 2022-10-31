import Foundation

struct BookCellViewModel: Identifiable {
    // MARK: - Properties

    let book: Book

    var id: UUID { book.id }
    var title: String { book.title }
    var author: String { book.author }
    var genres: String {
        book.genres.map(\.name).joined(separator: ", ")
    }
}
