import Combine
import SwiftUI

final class AnimSubmitButtonViewModel: ObservableObject {
    // MARK: - Properties

    let labels: (initial: String, completed: String)

    private var _action: (() -> Void)?
    var action: () -> Void {
        get {{ [weak self] in guard let self = self else { return }
            guard self.isActive else { return }
            self.isAnimating = true
            self._action?()
        }}
        set { _action = newValue }
    }

    @Published
    var buttonState: SubmitState = .enabled
    var isActive: Bool { buttonState == .enabled || buttonState == .enabledAgain }
    var isCompleted: Bool { buttonState == .completed }

    @Published
    private(set) var isAnimating = false
    @Published
    private(set) var systemImage: String = "lock.fill"
    @Published
    private(set) var bgColor: Color = Color("buttoonBackgroundColor")

    private var subscriptions = Set<AnyCancellable>()

    // MARK: - Initialization

    init(labels: (initial: String, completed: String),
         action: (() -> Void)? = nil)
    {
        self.labels = labels
        self._action = action

        $buttonState.sink { [weak self] buttonState in
            guard let self = self else { return }
            switch buttonState {
            case .enabled, .enabledAgain:
                self.systemImage = "lock.fill"
                self.bgColor = Color("buttoonBackgroundColor")
            case .disabled:
                self.systemImage = "xmark.circle"
                self.bgColor = .gray
            case .completed:
                self.systemImage = "lock.open.fill"
                self.bgColor = .gray
            }

            switch buttonState {
            case .enabledAgain, .completed:
                self.isAnimating = false
            default: break
            }
        }
        .store(in: &subscriptions)
    }

    // MARK: - Types

    enum SubmitState {
        case enabled
        case enabledAgain // Since Binding is all state, rather than state increments (as would be the case with publishers), we need this extra state to reflect a special case of resetting animation (in case of form submission failure).
        case disabled
        case completed
    }
}
