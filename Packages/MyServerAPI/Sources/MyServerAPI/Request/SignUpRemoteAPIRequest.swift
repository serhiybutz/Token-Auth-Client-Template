import Foundation
import SwiftUI

struct SignUpRemoteAPIRequest: APIRequestComposer {
    // MARK: - Properties

    let request: URLRequest

    // MARK: - Initialization

    init?(newAccount: NewAccount, serverSettings: Binding<ServerSettings>) {

        let endpointSpecProvider = EndpointSpec()

        guard let data = try? JSONEncoder().encode(newAccount) else { return nil }
        let requestSpecProvider = RequestSpec(httpBody: data)

        guard let request = RemoteAPIRequest(endpointSpecProvider, requestSpecProvider, settings: .init(server: serverSettings)) else { return nil }

        self.request = request.request
    }

    // MARK: - Types

    struct EndpointSpec: RemoteAPIEndpointSpecProvider {
        let path: String = "users/signup"
        let queryItems: [URLQueryItem]? = nil
    }

    struct RequestSpec: RemoteAPIRequestSpecProvider {
        let httpMethod: String? = "POST"
        let headerFields: [(field: String, value: String)]? = [
            (field: "Content-Type", value: "application/json; charset=utf-8")
        ]
        let httpBody: Data?
    }
}
