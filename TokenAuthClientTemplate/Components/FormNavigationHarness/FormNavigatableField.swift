import SwiftUI

extension View {

    func formNavigatableField<T: FormNavigatableView>(_ navigatableView: T, field: T.FormFieldEnum) -> some View {

        modifier(FormNavigatableFieldModifier(navigatableView, field: field))
    }
}

struct FormNavigatableFieldModifier<T: FormNavigatableView>: ViewModifier {

    let navigatableView: T

    var focusedFieldFocusState: FocusState<T.FormFieldEnum?> {
        navigatableView.focusedFieldFocusState
    }
    var focusedFieldFocusStateBinding: FocusState<T.FormFieldEnum?>.Binding {
        navigatableView.focusedFieldFocusStateBinding
    }

    let field: T.FormFieldEnum

    init(_ navigatableView: T, field: T.FormFieldEnum) {
        self.navigatableView = navigatableView
        self.field = field
    }

    func body(content: Content) -> some View {
        return content
            .submitLabel(field.isLast ? .done : .next)
            .focused(focusedFieldFocusStateBinding, equals: field)
    }
}
