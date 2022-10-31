import Foundation
import SwiftUI

struct AccountExistsRemoteAPIRequest: APIRequestComposer {
    // MARK: - Properties

    let request: URLRequest

    // MARK: - Initialization

    init?(username: String, caseSensitive: Bool?, serverSettings: Binding<ServerSettings>) {

        let endpointSpecProvider = EndpointSpec(username: username, caseSensitive: caseSensitive)

        let requestSpecProvider = RequestSpec()

        let settings = RemoteAPIRequestSettings(
            server: serverSettings,
            timeoutInterval: Constants.AccountExistRequestTimeout
        )

        guard let request = RemoteAPIRequest(
            endpointSpecProvider,
            requestSpecProvider,
            settings: settings) else { return nil }

        self.request = request.request
    }

    // MARK: - Types

    struct EndpointSpec: RemoteAPIEndpointSpecProvider {

        let path: String = "users/exists"
        let queryItems: [URLQueryItem]?

        init(username: String, caseSensitive: Bool?) {

            var queryItems = [
                URLQueryItem(name: "username", value: username)
            ]
            if let caseSensitive = caseSensitive {
                queryItems.append(URLQueryItem(name: "case_sensitive", value: caseSensitive ? "1" : "0"))
            }
            self.queryItems = queryItems
        }
    }

    struct RequestSpec: RemoteAPIRequestSpecProvider {

        let httpMethod: String? = "GET"
        let headerFields: [(field: String, value: String)]? = [
            (field: "Content-Type", value: "application/json; charset=utf-8")
        ]
        let httpBody: Data? = nil
    }
}
