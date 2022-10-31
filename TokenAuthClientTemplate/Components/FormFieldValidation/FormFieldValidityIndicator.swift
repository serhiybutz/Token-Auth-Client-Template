import SwiftUI

enum FieldValidityStatus: Equatable {
    /// Initial state with empty data.
    case empty
    /// "Half-valid" (minimun requirements are not met).
    case insufficient
    /// Waiting server validation.
    case waiting
    case invalid
    case valid
}

extension View {

    func formFieldValidityIndicator(_ validity: Binding<FieldValidityStatus>) -> some View {
        modifier(FormFieldValidityIndicator(validity: validity))
    }
}

struct FormFieldValidityIndicator: ViewModifier {

    @Binding var validity: FieldValidityStatus

    func body(content: Content) -> some View {

        HStack {

            content

            Group {
                switch validity {
                case .empty:

                    Image(systemName: "circle.fill")
                        .foregroundColor(.clear)

                case .insufficient:

                    Image(systemName: "exclamationmark.triangle.fill")
                        .renderingMode(.original)

                case .waiting:

                    ProgressView()
                        .frame(width: 16, height: 16)

                case .invalid:

                    Image(systemName: "xmark.circle")
                        .renderingMode(.original)

                case .valid:

                    Image(systemName: "checkmark")
                        .foregroundColor(.green)

                }
            }
            .frame(width: 16)
        }
    }
}

