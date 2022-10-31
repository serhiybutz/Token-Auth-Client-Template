import Foundation
import SwiftUI

struct GetBooksRemoteAPIRequest: APIRequestComposer {
    // MARK: - Properties

    let request: URLRequest

    // MARK: - Initialization

    init?(arguments: GetBooksArguments? = nil, token: String, serverSettings: Binding<ServerSettings>) {

        let endpointSpecProvider = EndpointSpec(arguments: arguments)

        let requestSpecProvider = RequestSpec(token: token)

        guard let request = RemoteAPIRequest(endpointSpecProvider, requestSpecProvider, settings: .init(server: serverSettings)) else { return nil }

        self.request = request.request
    }

    // MARK: - Types

    struct EndpointSpec: RemoteAPIEndpointSpecProvider {

        let path: String = "books"
        let queryItems: [URLQueryItem]?

        init(arguments: GetBooksArguments?) {

            var queryItems: [URLQueryItem] = []
            if let filter = arguments?.filter {
                queryItems.append(URLQueryItem(name: "filter", value: filter))
            }
            if let sortField = arguments?.sortField {
                queryItems.append(URLQueryItem(name: "sort_field", value: sortField.rawValue))
            }
            if let sortDirection = arguments?.sortDirection {
                queryItems.append(URLQueryItem(name: "sort_direction", value: sortDirection.rawValue))
            }
            self.queryItems = queryItems
        }
    }

    struct RequestSpec: RemoteAPIRequestSpecProvider {

        let httpMethod: String? = "GET"
        let headerFields: [(field: String, value: String)]?
        let httpBody: Data? = nil

        init(token: String) {

            headerFields = [
                (field: "Authorization", value: "Bearer \(token)")
            ]
        }
    }
}
