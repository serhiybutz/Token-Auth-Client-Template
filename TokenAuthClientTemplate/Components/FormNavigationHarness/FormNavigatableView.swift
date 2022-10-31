import SwiftUI

protocol FormNavigatableView: View {

    associatedtype FormFieldEnum: NavigatableFormFieldEnum where FormFieldEnum.AllCases.Index == Int

    var focusedFieldFocusState: FocusState<FormFieldEnum?> { get }
    var focusedFieldFocusStateBinding: FocusState<FormFieldEnum?>.Binding { get }
}

extension FormNavigatableView {

    func resignKeyboard() {

        if #available(iOS 15, *) {

            focusedFieldFocusState.wrappedValue = nil
        } else {

            dismissKeyboard()
        }
    }

    func dismissKeyboard() {

        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}
