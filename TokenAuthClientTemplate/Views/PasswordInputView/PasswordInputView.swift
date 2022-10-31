import SwiftUI

struct PasswordInputView: View {

    @Binding private var text: String
    @State private var isSecured: Bool = true
    private let title: String
    private let unsecuredTimeout: TimeInterval?

    init(_ title: String, text: Binding<String>, unsecuredTimeout: TimeInterval? = nil) {

        self.title = title
        self._text = text
        self.unsecuredTimeout = unsecuredTimeout
    }

    var body: some View {

        ZStack(alignment: .trailing) {

            Group {
                if isSecured {
                    SecureField(title, text: $text)
                } else {
                    TextField(title, text: $text)
                }
            }
            .textContentType(.password)
            .disableAutocorrection(true)
            .textInputAutocapitalization(.never)
            .padding(.trailing, 32)

            Button(action: {

                if isSecured {

                    isSecured = false

                    if let unsecuredTimeout = unsecuredTimeout {

                        Task {

                            try await Task.sleep(nanoseconds: UInt64(unsecuredTimeout * 1_000_000_000))

                            await MainActor.run {
                                isSecured = true
                            }
                        }
                    }
                } else {

                    isSecured = true
                }
            }) {

                Image(systemName: self.isSecured ? "eye.slash" : "eye")
                    .accentColor(.gray)
            }
        }
    }
}
