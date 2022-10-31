import Foundation
import SwiftUI

protocol RemoteAPIRequestSpecProvider {
    
    var httpMethod: String? { get }
    var headerFields: [(field: String, value: String)]? { get }
    var httpBody: Data? { get }
}

struct RemoteAPIRequest<T: RemoteAPIEndpointSpecProvider, U: RemoteAPIRequestSpecProvider> {
    // MARK: - Properties
    
    let request: URLRequest
    
    // MARK: - Initialization
    
    init?(_ endpointSpecProvider: T, _ requestSpecProvider: U, settings: RemoteAPIRequestSettings) {
        
        guard let endpointURL = RemoteAPIEndpoint(endpointSpecProvider, serverSettings: settings.server)?.url else { return nil }
        
        var request = URLRequest(url: endpointURL)
        
        request.httpMethod = requestSpecProvider.httpMethod
        
        if let fields = requestSpecProvider.headerFields {
            fields.forEach {
                request.addValue($0.value, forHTTPHeaderField: $0.field)
            }
        }
        
        if let body = requestSpecProvider.httpBody {
            request.httpBody = body
        }
        
        if let timeout = settings.timeoutInterval {
            request.timeoutInterval = timeout
        }
        
        self.request = request
    }
}

// MARK: - Types

struct RemoteAPIRequestSettings {
    let server: Binding<ServerSettings>
    let timeoutInterval: TimeInterval?
    init(server: Binding<ServerSettings>, timeoutInterval: TimeInterval? = nil) {
        self.server = server
        self.timeoutInterval = timeoutInterval
    }
}
