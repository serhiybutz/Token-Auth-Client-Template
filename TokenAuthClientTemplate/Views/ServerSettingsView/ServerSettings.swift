import Foundation
import OSLog

enum URLScheme: String, Codable {
    case http, https
}

struct ServerSettings: Equatable {
    // MARK: - Default values

    static var DefaultScheme: URLScheme = Constants.Server.DefaultScheme
    static var DefaultHost: String = Constants.Server.DefaultHost
    static var DefaultPort: Int = Constants.Server.DefaultPort
    static var DefaultRootSegment: String = Constants.Server.DefaultRootSegment

    // MARK: - Properties

    var scheme: URLScheme
    var host: String
    var port: Int?
    var rootSegment: String

    // MARK: - Initialization

    init(scheme: URLScheme = Self.DefaultScheme,
         host: String = Self.DefaultHost,
         port: Int? = Self.DefaultPort,
         rootSegment: String = Self.DefaultRootSegment) {

            self.scheme = scheme
            self.host = host
            self.port = port
            self.rootSegment = rootSegment
        }
}

extension ServerSettings: Codable {

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        scheme = try values.decode(URLScheme.self, forKey: .scheme)
        host = try values.decode(String.self, forKey: .host)
        port = try values.decode(Int?.self, forKey: .port)
        rootSegment = try values.decode(String.self, forKey: .rootSegment)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(scheme, forKey: .scheme)
        try container.encode(host, forKey: .host)
        try container.encode(port, forKey: .port)
        try container.encode(rootSegment, forKey: .rootSegment)
    }

    // MARK: - Types

    enum CodingKeys : String, CodingKey {
        case scheme, host, port, rootSegment
    }
}

extension ServerSettings: RawRepresentable {

    init?(rawValue: String) {

        guard let data = rawValue.data(using: .utf8) else {

            os_log(.error, log: OSLog.default, "[ServerSettings] Decoding failed: Invalid data [\(rawValue.truncateWithEllipsis(at: 100))]")
            return nil
        }

        do {
            let result = try JSONDecoder().decode(ServerSettings.self, from: data)
            self = result
        } catch {

            os_log(.error, log: OSLog.default, "[ServerSettings] Decoding failed: \(error.localizedDescription) [\(rawValue.truncateWithEllipsis(at: 100))]")
            return nil
        }
    }

    var rawValue: String {

        do {
            let data = try JSONEncoder().encode(self)
            if let result = String(data: data, encoding: .utf8) {
                os_log(.info, log: OSLog.default, "[ServerSettings] Encoded value: \(result)")
                return result
            } else {
                os_log(.error, log: OSLog.default, "[ServerSettings] Encoding failed")
            }
        } catch {
            os_log(.error, log: OSLog.default, "[ServerSettings] Encoding failed: \(error.localizedDescription)")
        }

        return "[]"
    }
}

extension String {

    func truncateWithEllipsis(at maxCount: Int) -> String {
        count > maxCount
            ? prefix(maxCount) + "…"
            : self
    }
}
