import Foundation

protocol UserSessionRepository {

    func signUp(newAccount: NewAccount) async throws -> UserSession
    func signIn(username: String, password: String) async throws -> UserSession
    func signOut() async throws
    func accountExists(username: String, caseSensitive: Bool?) async throws -> Bool

    func getUserSession() async -> UserSession?
    func clearUserSession() async
    
    func getBooks(with arguments: GetBooksArguments?, _ remoteUserSession: RemoteUserSession) async throws -> [Book]
}

extension UserSessionRepository {

    func accountExists(username: String) async throws -> Bool {
        try await accountExists(username: username, caseSensitive: nil)
    }

    func getBooks(_ remoteUserSession: RemoteUserSession) async throws -> [Book] {
        try await getBooks(with: nil, remoteUserSession)
    }
}

struct GetBooksArguments {

    // MARK: - Properties

    var filter: String?
    var sortField: SortField?
    var sortDirection: SortDirection?

    // MARK: - Types
    
    enum SortField: String {
        case title, author
    }

    enum SortDirection: String {
        case ascending, descending
    }
}
