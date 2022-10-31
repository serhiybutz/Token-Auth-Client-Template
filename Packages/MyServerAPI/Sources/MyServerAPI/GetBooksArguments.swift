import Foundation

public struct GetBooksArguments {
    // MARK: - Properties

    public let filter: String?

    public let sortField: SortField?
    public let sortDirection: SortDirection?

    // MARK: - Initializer

    public init(filter: String? = nil, sortField: SortField? = nil, sortDirection: SortDirection? = nil) {
        
        self.filter = filter
        self.sortField = sortField
        self.sortDirection = sortDirection
    }

    // MARK: - Types

    public enum SortField: String {
        case title, author
    }

    public enum SortDirection: String {
        case ascending, descending
    }
}
