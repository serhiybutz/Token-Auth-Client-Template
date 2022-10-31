import Foundation
import SwiftUI

public struct Client {
    // MARK: - Properties

    let serverSettings: Binding<ServerSettings>
    let urlSession: URLSession

    // MARK: - Initialization

    public init(serverSettings: Binding<ServerSettings>, urlSession: URLSession = .shared) {

        self.serverSettings = serverSettings
        self.urlSession = urlSession
    }

    // MARK: - API

    public func signUp(newAccount: NewAccount) async throws -> UserSession {

        try await makeRequest(
            requestCompose: { SignUpRemoteAPIRequest(newAccount: newAccount, serverSettings: serverSettings) },
            payloadType: SignInUpResponse.self,
            transform: { payload in
                UserSession(
                    credentials: .init(username: newAccount.username, password: newAccount.password)!,
                    profile: payload.profile,
                    remoteUserSession: RemoteUserSession(
                        token: payload.token)
                )
            },
            decodingFailureHandler: authenticatedRequestError
        )
    }

    public func signIn(credentials: Credentials) async throws -> UserSession {

        try await makeRequest(
            requestCompose: { SignInRemoteAPIRequest(credentials: credentials, serverSettings: serverSettings) },
            payloadType: SignInUpResponse.self,
            transform: { payload in
                UserSession(
                    credentials: credentials,
                    profile: payload.profile,
                    remoteUserSession: RemoteUserSession(
                        token: payload.token)
                )
            },
            decodingFailureHandler: authenticatedRequestError
        )
    }

    public func accountExists(username: String, caseSensitive: Bool? = nil) async throws -> Bool {

        try await makeRequest(
            requestCompose: { AccountExistsRemoteAPIRequest(username: username, caseSensitive: caseSensitive, serverSettings: serverSettings) },
            payloadType: Bool.self,
            transform: { $0 },
            decodingFailureHandler: unauthenticatedRequestError
        )
    }

    public func getBooks(with arguments: GetBooksArguments? = nil, _ remoteUserSession: RemoteUserSession) async throws -> [Book] {

        try await makeRequest(
            requestCompose: { GetBooksRemoteAPIRequest(arguments: arguments, token: remoteUserSession.token, serverSettings: serverSettings) },
            payloadType: [Book].self,
            transform: { $0 },
            decodingFailureHandler: authenticatedRequestError
        )
    }

    // MARK: - Helpers

    private func makeRequest<T: APIRequestComposer, P: Decodable, R>(
        requestCompose: () -> T?,
        payloadType: P.Type,
        transform: (P) -> R,
        decodingFailureHandler: (Data) throws -> Never
    ) async throws -> R {

        guard let request = requestCompose()?.request
        else {
            throw ErrorType.invalidURL
        }

        let data: Data
        do {
            (data, _) = try await urlSession.data(for: request)
        } catch {

            throw ErrorType.transport(error as! URLError)
        }

        if let payload = try? JSONDecoder().decode(payloadType.self, from: data) {

            return transform(payload)

        } else {

            try decodingFailureHandler(data)
        }
    }

    private let authenticatedRequestError: (Data) throws -> Never = { data in

        if let errorPayload = try? JSONDecoder().decode(ErrorResponse.self, from: data) {

            if errorPayload.error {

                switch errorPayload.reason.lowercased() {
                case "unauthorized":
                    throw ErrorType.invalidCredentials
                case "constraint: unique constraint failed: users.username":
                    throw ErrorType.duplicateUsername
                default:
                    throw ErrorType.server(reason: errorPayload.reason)
                }
            } else {

                throw ErrorType.invalidResponse(String(data: data, encoding: .utf8))
            }
        }

        throw ErrorType.decodingFailed
    }

    private let unauthenticatedRequestError: (Data) throws -> Never = { _ in

        throw ErrorType.decodingFailed
    }
}

extension Client {

    public enum ErrorType: Error, LocalizedError, Equatable {

        case invalidURL
        case invalidCredentials
        case duplicateUsername
        case transport(URLError)
        case decodingFailed
        case invalidResponse(String?)
        case server(reason: String)
        case custom(errorMessage: String)

        public var errorDescription: String? {
            switch self {
            case .invalidURL:
                return NSLocalizedString("Invalind URL.", comment: "")
            case .invalidCredentials:
                return NSLocalizedString("Invalid credentials.", comment: "")
            case .duplicateUsername:
                return NSLocalizedString("User already exists.", comment: "")
            case .transport(let error):
                return NSLocalizedString("Transport error: \(error.localizedDescription)", comment: "")
            case .decodingFailed:
                return NSLocalizedString("Decoding failed.", comment: "")
            case .invalidResponse(let errorMessage):
                return NSLocalizedString("Invalid response\(errorMessage.map { ": \($0)" } ?? "")", comment: "")
            case .server(let reason):
                return NSLocalizedString("Server error: \(reason)", comment: "")
            case .custom(let errorMessage):
                return errorMessage
            }
        }
    }
}
