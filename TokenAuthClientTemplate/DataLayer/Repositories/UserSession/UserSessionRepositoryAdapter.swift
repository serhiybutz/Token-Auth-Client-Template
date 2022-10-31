import Foundation
import OSLog
import MyServerAPI

final class UserSessionRepositoryAdapter: UserSessionRepository {
    // MARK: - Properties

    let dataStore: UserSessionDataStore
    let remoteAPI: MyServerAPI.Client

    // MARK: - Initialization

    init(dataStore: UserSessionDataStore, remoteAPI: MyServerAPI.Client) {

        self.dataStore = dataStore
        self.remoteAPI = remoteAPI
    }

    // MARK: - API

    func signUp(newAccount: NewAccount) async throws -> UserSession {

        let apiUserSession = try await remoteAPI.signUp(newAccount: MyServerAPI.NewAccount(from: newAccount))
        let userSession = UserSession(from: apiUserSession)
        try await dataStore.save(userSession: userSession)
        return userSession
    }

    func signIn(username: String, password: String) async throws -> UserSession {

        guard let credentials = MyServerAPI.Credentials(
            username: username,
            password: password) else {
            throw ErrorType.invalidCredentials
        }

        let apiUserSession = try await remoteAPI.signIn(credentials: credentials)
        let userSession = UserSession(from: apiUserSession)
        try await dataStore.save(userSession: userSession)
        return userSession
    }

    func signOut() async throws {

        var userSession = await getUserSession()
        guard userSession != nil else { return }

        userSession!.status = .loggedOut
        try await dataStore.save(userSession: userSession!)
    }

    func accountExists(username: String, caseSensitive: Bool? = nil) async throws -> Bool {

        try await remoteAPI.accountExists(username: username, caseSensitive: caseSensitive)
    }

    func getUserSession() async -> UserSession? {

        do {
            return try await dataStore.readUserSession()
        } catch {
            os_log(.error, log: OSLog.default, "[UserSession] Failed to read user session: \(error.localizedDescription)")
            return nil
        }
    }

    func clearUserSession() async {

        do {
            try await dataStore.delete()
        } catch {
            os_log(.error, log: OSLog.default, "[UserSession] Failed to clear user session: \(error.localizedDescription)")
        }
    }

    func getBooks(with arguments: GetBooksArguments?, _ remoteUserSession: RemoteUserSession) async throws -> [Book] {

        try await remoteAPI.getBooks(with: arguments.map(MyServerAPI.GetBooksArguments.init), MyServerAPI.RemoteUserSession(from: remoteUserSession))
            .map { Book(from: $0) }
    }
}

extension UserSessionRepositoryAdapter {

    enum ErrorType: Error, LocalizedError, Equatable {

        case invalidCredentials

        var errorDescription: String? {

            switch self {
            case .invalidCredentials:
                return NSLocalizedString("Invalid credentials.", comment: "")
            }
        }
    }
}

extension TokenAuthClientTemplate.UserSession {

    init(from source: MyServerAPI.UserSession) {

        self.credentials = Credentials(from: source.credentials)
        let remoteUserSession = RemoteUserSession(from: source.remoteUserSession)
        let userProfile = UserProfile(from: source.profile)
        self.status = .loggedIn(remoteUserSession: remoteUserSession, userProfile: userProfile)
    }
}

extension TokenAuthClientTemplate.Credentials {

    init(from source: MyServerAPI.Credentials) {

        self.username = source.username
        self.password = source.password
    }
}

extension TokenAuthClientTemplate.UserProfile {

    init(from source: MyServerAPI.UserProfile) {

        self.fullname = source.fullname
        self.email = source.email
        self.phone = source.phone
        self.avatar = source.avatar
    }
}

extension TokenAuthClientTemplate.RemoteUserSession {

    init(from source: MyServerAPI.RemoteUserSession) {

        self.token = source.token
    }
}

extension MyServerAPI.RemoteUserSession {

    init(from source: TokenAuthClientTemplate.RemoteUserSession) {
        self.init(token: source.token)
    }
}

extension MyServerAPI.NewAccount {

    init(from source: TokenAuthClientTemplate.NewAccount) {

        self.init(
            fullname: source.fullname,
            username: source.username,
            email: source.email,
            phone: source.phone,
            password: source.password)
    }
}

extension TokenAuthClientTemplate.Book {

    init(from source: MyServerAPI.Book) {

        self.id = source.id
        self.title = source.title
        self.author = source.author
        self.genres = source.genres.map { TokenAuthClientTemplate.Genre(from: $0) }
    }
}

extension TokenAuthClientTemplate.Genre {

    init(from source: MyServerAPI.Genre) {

        self.id = source.id
        self.name = source.name
    }
}

extension MyServerAPI.GetBooksArguments {

    init(from source: TokenAuthClientTemplate.GetBooksArguments) {

        self.init(
            filter: source.filter,
            sortField: source.sortField.map(MyServerAPI.GetBooksArguments.SortField.init),
            sortDirection: source.sortDirection.map(MyServerAPI.GetBooksArguments.SortDirection.init))
    }
}

extension MyServerAPI.GetBooksArguments.SortField {

    init(from source: TokenAuthClientTemplate.GetBooksArguments.SortField) {
        switch source {
        case .title: self = .title
        case .author: self = .author
        }
    }
}

extension MyServerAPI.GetBooksArguments.SortDirection {

    init(from source: TokenAuthClientTemplate.GetBooksArguments.SortDirection) {
        switch source {
        case .ascending: self = .ascending
        case .descending: self = .descending
        }
    }
}

extension MyServerAPI.ServerSettings {

    init(from source: TokenAuthClientTemplate.ServerSettings) {

        let scheme: MyServerAPI.URLScheme
        switch source.scheme {
        case .http: scheme = .http
        case .https: scheme = .https
        }
        self.init(scheme: scheme, host: source.host, port: source.port, rootSegment: source.rootSegment)
    }
}
