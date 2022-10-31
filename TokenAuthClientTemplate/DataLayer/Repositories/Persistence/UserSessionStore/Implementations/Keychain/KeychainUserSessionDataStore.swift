import Foundation
import KeychainSecretStore
import OSLog

final class KeychainUserSessionDataStore: UserSessionDataStore {

    // MARK: - Properties

    let userSessionCoder: UserSessionCoding
    let secretStore: KeychainInternetSecretStore

    // MARK: - Initialization

    init(userSessionCoder: UserSessionCoding, storeServer: String) {

        self.userSessionCoder = userSessionCoder
        self.secretStore = KeychainInternetSecretStore(server: storeServer)
    }

    // MARK: - API

    func readUserSession() async throws -> UserSession? {
        do {
            let data = try self.secretStore.load()
            let userSession = self.userSessionCoder.decode(data: data)
            return userSession
        } catch {
            if let err = error as? KeychainInternetSecretStore.ErrorType, err == .itemNotFound {

                os_log(.info, log: OSLog.default, "[KeychainUserSessionDataStore] User session not found.")
                return nil
            } else {
                throw error
            }
        }
    }

    func save(userSession: UserSession) async throws {
        let data = self.userSessionCoder.encode(userSession: userSession)

        var shouldUpdate: Bool = true
        do {
            _ = try self.secretStore.load()
        } catch {
            if let err = error as? KeychainInternetSecretStore.ErrorType, err == .itemNotFound {
                shouldUpdate = false
            } else {
                throw error
            }
        }

        if shouldUpdate {
            try self.secretStore.update(data: data)
        } else {
            try self.secretStore.add(data: data)
        }
    }

    func delete() async throws {
        do {
            try self.secretStore.delete()
        } catch {
            if let err = error as? KeychainInternetSecretStore.ErrorType, err == .itemNotFound {
                return
            } else {
                throw error
            }
        }
    }
}
