import Foundation

protocol UserSessionCoding {

    func encode(userSession: UserSession) -> Data
    func decode(data: Data) -> UserSession
}
