import Foundation
import SwiftUI

protocol RemoteAPIEndpointSpecProvider {

    var path: String { get }
    var queryItems: [URLQueryItem]? { get }
}

struct RemoteAPIEndpoint<T: RemoteAPIEndpointSpecProvider> {
    // MARK: - Properties

    let url: URL

    // MARK: - Initialization

    init?(_ specProvider: T, serverSettings: Binding<ServerSettings>) {

        func normalizeSegment(_ str: String) -> String {
            let str = str.trimmingCharacters(in: .whitespacesAndNewlines)
            return str.prefix(1) == "/"
            ? str
            : "/\(str)"
        }

        let serverSettings = serverSettings.wrappedValue

        var components = URLComponents()
        components.scheme = serverSettings.scheme.rawValue
        components.host = serverSettings.host
        if let port = serverSettings.port {
            components.port = port
        }
        components.path = [serverSettings.rootSegment, specProvider.path]
            .map(normalizeSegment).joined()
        components.queryItems = (specProvider.queryItems ?? []).isEmpty
        ? nil
        : specProvider.queryItems

        guard let url = components.url else { return nil }

        self.url = url
    }
}
