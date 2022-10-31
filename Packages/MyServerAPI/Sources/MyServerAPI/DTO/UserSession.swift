import Foundation

public struct UserSession: Codable, Equatable {
    // MARK: - Properties

    public let credentials: Credentials
    public let profile: UserProfile
    public let remoteUserSession: RemoteUserSession

    // MARK: - Initializer

    public init(credentials: Credentials, profile: UserProfile, remoteUserSession: RemoteUserSession) {
        
        self.credentials = credentials
        self.profile = profile
        self.remoteUserSession = remoteUserSession
    }
}
