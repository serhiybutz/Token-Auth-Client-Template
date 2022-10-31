import Foundation

struct UserSessionPropertyListCoder: UserSessionCoding {

    func encode(userSession: UserSession) -> Data {

        try! PropertyListEncoder().encode(userSession)
    }

    func decode(data: Data) -> UserSession {

        try! PropertyListDecoder().decode(UserSession.self, from: data)
    }
}
