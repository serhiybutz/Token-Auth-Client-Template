import Foundation
import Security

public struct KeychainInternetSecretStore {

    // MARK: - Properties

    let server: String
    let account: String?

    // MARK: - Initialization

    public init(server: String, account: String? = nil) {

        self.server = server
        self.account = account
    }

    // MARK: - API
    
    public func add(data: Data) throws {

        var query: [CFString: Any] = [
            kSecClass: kSecClassInternetPassword,
            kSecAttrServer: server,
            kSecValueData: data,
        ]
        if let account = account {
            query[kSecAttrAccount] = account
        }
        let status = SecItemAdd(query as CFDictionary, nil)
        guard status == errSecSuccess else {
            throw ErrorType(status: status)
        }
    }

    public func update(data: Data) throws {

        var query: [CFString: Any] = [
            kSecClass: kSecClassInternetPassword,
            kSecAttrServer: server
        ]
        if let account = account {
            query[kSecAttrAccount] = account
        }
        let updateFields = [
            kSecValueData: data
        ] as CFDictionary
        if let account = account {
            query[kSecAttrAccount] = account
        }
        let status = SecItemUpdate(query as CFDictionary, updateFields)
        guard status == errSecSuccess else {
            throw ErrorType(status: status)
        }
    }

    public func load() throws -> Data {

        var query: [CFString: Any] = [
            kSecClass: kSecClassInternetPassword,
            kSecAttrServer: server,
            kSecReturnData: true,
            kSecMatchLimit: kSecMatchLimitOne // (by default)
        ]
        if let account = account {
            query[kSecAttrAccount] = account
        }
        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        guard status == errSecSuccess else {
            throw ErrorType(status: status)
        }
        return result as! Data
    }

    public func delete() throws {

        var query: [CFString: Any] = [
            kSecClass: kSecClassInternetPassword,
            kSecAttrServer: server
        ]
        if let account = account {
            query[kSecAttrAccount] = account
        }
        let status = SecItemDelete(query as CFDictionary)
        guard status == errSecSuccess else {
            throw ErrorType(status: status)
        }
    }
}

extension KeychainInternetSecretStore {

    public enum ErrorType: Error, LocalizedError, Equatable {

        case duplicateItem
        case itemNotFound
        case other(status: OSStatus)

        init(status: OSStatus) {

            switch status {
            case errSecDuplicateItem:
                self = .duplicateItem
            case errSecItemNotFound:
                self = .itemNotFound
            default:
                self = .other(status: status)
            }
        }

        public var errorDescription: String? {

            switch self {
            case .duplicateItem:
                return SecCopyErrorMessageString(errSecDuplicateItem, nil) as String?
            case .itemNotFound:
                return SecCopyErrorMessageString(errSecItemNotFound, nil) as String?
            case .other(let status):
                return SecCopyErrorMessageString(status, nil) as String?
            }
        }
    }
}
