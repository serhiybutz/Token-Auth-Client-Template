import Foundation

extension Result where Failure == Swift.Error {

    // Async initializer version of:
    //    init(catching body: () throws -> Success)
    init(catching body: () async throws -> Success) async {

        do {
            self = .success(try await body())
        } catch {
            self = .failure(error)
        }
    }

    func throwing() throws -> Success {
        switch self {
        case .success(let value):
            return value
        case .failure(let error):
            throw error
        }
    }
}
