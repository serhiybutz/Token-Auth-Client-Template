import Foundation

public enum URLScheme: String, Codable {
    case http, https
}

public struct ServerSettings: Equatable {
    // MARK: - Properties

    public let scheme: URLScheme
    public let host: String
    public let port: Int?
    public let rootSegment: String

    // MARK: - Initialization

    public init(
        scheme: URLScheme,
        host: String,
        port: Int?,
        rootSegment: String) {

        self.scheme = scheme
        self.host = host
        self.port = port
        self.rootSegment = rootSegment
    }
}

extension ServerSettings: Codable {

    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        scheme = try values.decode(URLScheme.self, forKey: .scheme)
        host = try values.decode(String.self, forKey: .host)
        port = try values.decode(Int?.self, forKey: .port)
        rootSegment = try values.decode(String.self, forKey: .rootSegment)
    }

    public func encode(to encoder: Encoder) throws {
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
