import Combine
import SwiftUI

enum FieldHighlight {
    case required
    case error
    case none
}

final class FormFieldHighlighting<Root: AnyObject> {
    // MARK: - Properties

    private let cancellable: AnyCancellable

    // MARK: - Initialization

    init(
        isRequired: Bool,
        submitCountProp: ReferenceWritableKeyPath<Root, Published<Int>>,
        validityProp: ReferenceWritableKeyPath<Root, Published<FieldValidityStatus>>,
        highlightProp: ReferenceWritableKeyPath<Root, FieldHighlight>,
        on root: Root
    ) {
        self.cancellable = root[keyPath: submitCountProp].projectedValue
            .combineLatest(root[keyPath: validityProp].projectedValue)
            .map { (submitCount, validity) -> FieldHighlight? in

                let submitted = submitCount > 0

                switch (isRequired, submitted,      validity) {
                case (           _,      true,      .invalid): return FieldHighlight.error
                case (           _,      true, .insufficient): return FieldHighlight.error
                case (        true,      true,        .empty): return FieldHighlight.error
                case (        true,      false,            _): return FieldHighlight.required
                default:                                       return FieldHighlight.none
                }
            }
            .sink { highlightOrNil in
                if let highlight = highlightOrNil {
                    root[keyPath: highlightProp] = highlight
                }
            }
    }

    // MARK: - API

    func retain(in store: inout [AnyObject]) {
        store.append(self)
    }
}
