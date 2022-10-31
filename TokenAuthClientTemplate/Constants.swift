import Foundation

enum Constants {

    enum KeychainStore {

        static let serverName = "com.irizen.AuthenticationServerClientTemplate.keychain.%@"
    }

    enum Server {

        static let UserDefaultsKey = "com.irizen.AuthenticationServerClientTemplate.serverSettings"

        static let DefaultScheme: URLScheme = .http
        static let DefaultHost: String = "localhost"
        static let DefaultPort: Int = 8080
        static let DefaultRootSegment: String = "api"
    }

    enum Account {

        static let MinUsernameLength: Int = 3
        static let MinPasswordLength: Int = 3
    }

    enum Security {

        static let UnsecuredPasswordTimeout: TimeInterval = 3
        static let PresentBioButtonForNoUserSession: Bool = true
    }
}
