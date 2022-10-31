import SwiftUI

extension View {

    func formNavigationHarness<T: FormNavigatableView>(_ navigatableView: T, onSubmit: (() -> Void)? = nil) -> some View {

        modifier(FormNavigationHarnessModifier(navigatableView, onSubmit: onSubmit))
    }
}

struct FormNavigationHarnessModifier<T: FormNavigatableView>: ViewModifier {

    let navigatableView: T
    var focusedFieldFocusState: FocusState<T.FormFieldEnum?> {
        navigatableView.focusedFieldFocusState
    }
    let onSubmit: (() -> Void)?

    init(_ navigatableView: T, onSubmit: (() -> Void)?) {
        self.navigatableView = navigatableView
        self.onSubmit = onSubmit
    }

    func body(content: Content) -> some View {
        content
            .toolbar {
                /// Note: It must be enclosed in a Navigation View!
                ToolbarItemGroup(placement: .keyboard) {

                    HStack(spacing: 16) {

                        Button(action: navigatableView.resignKeyboard) {
                            Image(systemName: "keyboard.chevron.compact.down")
                        }

                        Spacer()

                        Divider()

                        Button(action: { moveToPrevField() }) {
                            Image(systemName: "chevron.backward.square")
                        }
                        .disabled(focusedFieldFocusState.wrappedValue?.prev ?? nil == nil)

                        Divider()

                        Button(action: { moveToNextField() }) {
                            Image(systemName: "chevron.forward.square")
                        }
                        .disabled(focusedFieldFocusState.wrappedValue?.next ?? nil == nil)

                        if let onSubmit = onSubmit {

                            Divider()

                            Button(action: onSubmit) {
                                Image(systemName: "arrowshape.turn.up.right.fill")
                            }
                        } else {
                            EmptyView()
                        }
                    }
                    .font(.caption)
                }
            }
            .onSubmit {
                if let field = focusedFieldFocusState.wrappedValue {
                    if field.isLast {
                        onSubmit?()
                    } else {
                        moveToNextField()
                    }
                }
            }
    }

    func moveToPrevField() {

        focusedFieldFocusState.wrappedValue = focusedFieldFocusState.wrappedValue?.prev
    }

    func moveToNextField() {

        focusedFieldFocusState.wrappedValue = focusedFieldFocusState.wrappedValue?.next
    }
}
