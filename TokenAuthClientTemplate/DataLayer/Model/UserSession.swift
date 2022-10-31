import Foundation

struct UserSession: Codable {
    // MARK: - Properties

    let credentials: Credentials
    var status: Status

    var remoteUserSession: RemoteUserSession? {

        if case .loggedIn(let session, _) = status {
            return session
        } else {
            return nil
        }
    }

    var userProfile: UserProfile? {

        if case .loggedIn(_, let profile) = status {
            return profile
        } else {
            return nil
        }
    }

    var isLoggedIn: Bool {
        
        if case .loggedIn = status {
            return true
        } else {
            return false
        }
    }

    // MARK: - Types

    enum CodingKeys : String, CodingKey {
        case credentials, status
    }

    enum Status: Codable {
        case loggedIn(remoteUserSession: RemoteUserSession, userProfile: UserProfile)
        case loggedOut
    }
}
