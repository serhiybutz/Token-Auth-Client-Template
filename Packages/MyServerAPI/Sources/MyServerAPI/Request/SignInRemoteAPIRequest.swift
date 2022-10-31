import Foundation
import SwiftUI

struct SignInRemoteAPIRequest: APIRequestComposer {
    // MARK: - Properties
    
    let request: URLRequest
    
    // MARK: - Initialization
    
    init?(credentials: Credentials, serverSettings: Binding<ServerSettings>) {
        
        let endpointSpecProvider = EndpointSpec()
        
        let requestSpecProvider = RequestSpec(credentials: credentials)
        
        guard let request = RemoteAPIRequest(endpointSpecProvider, requestSpecProvider, settings: .init(server: serverSettings)) else { return nil }
        
        self.request = request.request
    }
    
    struct RequestSpec: RemoteAPIRequestSpecProvider {
        
        // MARK: - Properties
        
        let httpMethod: String? = "POST"
        let headerFields: [(field: String, value: String)]?
        let httpBody: Data? = nil
        
        // MARK: - Initialization
        
        init(credentials: Credentials) {
            
            let authString = "Basic \(credentials.asHTTPAuthEncoded)"
            
            self.headerFields = [
                (field: "Content-Type", value: "application/json; charset=utf-8"),
                (field: "Authorization", value: authString)
            ]
        }
    }
    
    struct EndpointSpec: RemoteAPIEndpointSpecProvider {
        let path: String = "users/signin"
        let queryItems: [URLQueryItem]? = nil
    }
}

extension Credentials {
    
    var asHTTPAuthEncoded: String {
        
        let userPasswordData = "\(username):\(password)".data(using: .utf8)!
        let base64EncodedCredentials = userPasswordData.base64EncodedString(options: [])
        return base64EncodedCredentials
    }
}
