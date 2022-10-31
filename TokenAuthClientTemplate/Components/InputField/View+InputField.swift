import Combine
import SwiftUI

enum InputKind {

    case text(textContentType: UITextContentType? = nil, keyboardType: UIKeyboardType? = nil)
    case password

    @ViewBuilder
    func view(prompt: String, inputBinding: Binding<String>) -> some View {
        switch self {
        case .text(let textContentType, let keyboardType):

            TextField(
                prompt,
                text: inputBinding)
            .textContentType(textContentType)
            .keyboardType(keyboardType ?? .default)

        case .password:

            PasswordInputView(
                prompt,
                text: inputBinding,
                unsecuredTimeout: Constants.Security.UnsecuredPasswordTimeout
            )
        }
    }
}

enum FieldValidation {
    case use(validityBinding: Binding<FieldValidityStatus>, highlightBinding: Binding<FieldHighlight>)
    case none
}

extension View where Self: FormNavigatableView {

    @ViewBuilder
    func inputField(
        title: String,
        prompt: String,
        inputBinding: Binding<String>,
        inputKind: InputKind,
        field: FormFieldEnum,
        validation: FieldValidation = .none
    ) -> some View {

        VStack(alignment: .leading) {

            Text(title)
                .font(.headline)
                .fontWeight(.light)
                .foregroundColor(Color(.label).opacity(0.75))

            if case let .use(validityBinding, highlightBinding) = validation {
                inputKind.view(prompt: prompt, inputBinding: inputBinding)
                    .highlightedField(highlightBinding)
                    .formNavigatableField(self, field: field)
                    .disableAutocorrection(true)
                    .textInputAutocapitalization(.never)
                    .textFieldStyle(.roundedBorder)
                    .formFieldValidityIndicator(validityBinding)
            } else {
                inputKind.view(prompt: prompt, inputBinding: inputBinding)
                    .formNavigatableField(self, field: field)
                    .disableAutocorrection(true)
                    .textInputAutocapitalization(.never)
                    .textFieldStyle(.roundedBorder)
            }
        }
        .padding(.bottom, 15)
    }
}

extension View {

    func highlightedField(_ highlight: Binding<FieldHighlight>) -> some View {

        let color: Color
        switch highlight.wrappedValue {
        case .required: color = Color.gray
        case .error: color = Color.red
        case .none: color = Color.clear
        }

        return self
            .overlay(RoundedRectangle(cornerRadius: 3)
                .stroke(color, lineWidth: 1))
    }
}
