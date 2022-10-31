import Foundation

protocol UserSessionDataStore {

    func readUserSession() async throws -> UserSession?
    func save(userSession: UserSession) async throws
    func delete() async throws
}
