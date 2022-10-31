import SwiftUI

struct SignUpView: View {

    @StateObject var viewModel: SignUpViewModel
    @FocusState private var focusedField: FormField?
    @StateObject var animSubmitButtonViewModel = AnimSubmitButtonViewModel(
        labels: (initial: "Sign Up", completed: "Done")
    )

    var body: some View {

        ScrollView {

            VStack {

                topView
                    .padding(.top, 30)
                    .padding(.bottom, 20)

                Group {

                    inputField(
                        title: "Full Name",
                        prompt: "Enter Your Full Name",
                        inputBinding: $viewModel.fullname,
                        inputKind: .text(textContentType: .username, keyboardType: .namePhonePad),
                        field: .fullName,
                        validation: .use(validityBinding: $viewModel.fullnameValidity, highlightBinding: $viewModel.fullnameHighlight))

                    inputField(
                        title: "Username",
                        prompt: "Enter Your Username",
                        inputBinding: $viewModel.username,
                        inputKind: .text(textContentType: .username, keyboardType: .namePhonePad),
                        field: .userName,
                        validation: .use(validityBinding: $viewModel.usernameValidity, highlightBinding: $viewModel.usernameHighlight))

                    inputField(
                        title: "Password",
                        prompt: "Enter Your Password",
                        inputBinding: $viewModel.password,
                        inputKind: .password,
                        field: .password,
                        validation: .use(validityBinding: $viewModel.passwordValidity, highlightBinding: $viewModel.passwordHighlight))

                    inputField(
                        title: "Repeat Password",
                        prompt: "Enter Your Password Again",
                        inputBinding: $viewModel.passwordAgain,
                        inputKind: .password,
                        field: .passwordAgain,
                        validation: .use(validityBinding: $viewModel.passwordAgainValidity, highlightBinding: $viewModel.passwordAgainHighlight))
                }

                Group {

                    inputField(
                        title: "Email",
                        prompt: "Enter Your Email Address",
                        inputBinding: $viewModel.email,
                        inputKind: .text(textContentType: .emailAddress, keyboardType: .emailAddress),
                        field: .email,
                        validation: .use(validityBinding: $viewModel.emailValidity, highlightBinding: $viewModel.emailHighlight))

                    inputField(
                        title: "Phone",
                        prompt: "Enter Your Phone Number",
                        inputBinding: $viewModel.phone,
                        inputKind: .text(textContentType: .telephoneNumber, keyboardType: .phonePad),
                        field: .phone,
                        validation: .use(validityBinding: $viewModel.phoneValidity, highlightBinding: $viewModel.phoneHighlight))

                    bottomView
                }
            }

            Spacer()
        }
        .formNavigationHarness(self, onSubmit: {
            signUp()
        })
        .embedInNavViewWithoutToolbar
        .onAppear {
            animSubmitButtonViewModel.action = {
                signUp()
            }
        }
        .padding(.horizontal)
    }

    @ViewBuilder
    var topView: some View {

        VStack {
            Image(systemName: "person.fill.badge.plus")
                .resizable()
                .scaledToFit()
                .frame(width: 50, height: 50)

            Text("Sign Up")
                .fontWeight(.heavy)
                .font(.title)
        }
    }

    @ViewBuilder
    var bottomView: some View {

        VStack {

            HStack {

                Spacer()

                AnimSubmitButton(viewModel: animSubmitButtonViewModel)

                Spacer()
            }
        }

        HStack(spacing: 8) {

            Text("Already Have an Account?")
                .foregroundColor(Color.gray.opacity(0.5))

            Button(action: {

                withAnimation {
                    viewModel.moveToSignIn()
                }
            }) {
                Text("Sign In")
            }
            .foregroundColor(.blue)
        }
        .padding(.top, 25)
    }

    func signUp() {

        Task.detached {

            await viewModel.signUp(animSubmitButtonViewModel)
            await MainActor.run {
                resignKeyboard()
            }
        }
    }
}

extension SignUpView: FormNavigatableView {

    enum FormField: NavigatableFormFieldEnum {
        case fullName, userName, password, passwordAgain, email, phone
    }

    var focusedFieldFocusState: FocusState<FormField?> { _focusedField }
    var focusedFieldFocusStateBinding: FocusState<FormField?>.Binding { $focusedField }
}
