import Combine
import SwiftUI

@MainActor
final class ErrorPresenterViewModel: ObservableObject {
    // MARK: - Properties

    @Published var error: Error?
    private var subscribers = Set<AnyCancellable>()

    // MARK: - API
    
    func subscribe(_ errorable: Errorable) {
        errorable
            .errorPublisher
            .receive(on: DispatchQueue.main)
            .sink {
                self.error = $0
            }
            .store(in: &subscribers)
    }
}
