import Foundation

protocol TrackLoadingTrait: AnyObject {
    @MainActor
    var isLoading: Bool { get set }
}

extension TrackLoadingTrait {

    func trackLoading<T>(exec: () async throws -> T) async throws -> T {

        await MainActor.run { self.isLoading = true }

        let result = await Result { try await exec() }

        await MainActor.run { self.isLoading = false }

        return try result.throwing()
    }

    func trackLoading<T>(exec: () async -> T) async -> T {

        await MainActor.run { self.isLoading = true }

        let result = await exec()

        await MainActor.run { self.isLoading = false }

        return result
    }
}
