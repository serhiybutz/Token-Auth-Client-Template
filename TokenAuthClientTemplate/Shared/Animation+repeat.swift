import SwiftUI

extension Animation {

    func `repeat`(while predicate: Bool, autoreverses: Bool = true) -> Animation {

        if predicate {
            return repeatForever(autoreverses: autoreverses)
        } else {
            return self
        }
    }
}
