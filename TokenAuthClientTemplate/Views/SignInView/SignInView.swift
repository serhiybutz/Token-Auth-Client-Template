import SwiftUI

struct SignInView: View {
    
    @ObservedObject var viewModel: SignInViewModel
    @FocusState private var focusedField: FormField?
    @StateObject var animSubmitButtonViewModel = AnimSubmitButtonViewModel(
        labels: (initial: "Sign In", completed: "Done")
    )
    @State var bioAuth: BiometricIDAuth? = try? BiometricIDAuth()
    @State var shouldShowServerSettings: Bool = false

    var body: some View {

        ScrollView {

            VStack {

                serverSettingsButton

                topView
                    .padding(.top, 15)
                    .padding(.bottom, 20)

                Group {

                    inputField(
                        title: "Username",
                        prompt: "Enter Your Username",
                        inputBinding: $viewModel.username,
                        inputKind: .text(textContentType: .username, keyboardType: .namePhonePad),
                        field: .userName)

                    inputField(
                        title: "Password",
                        prompt: "Enter Your Password",
                        inputBinding: $viewModel.password,
                        inputKind: .password,
                        field: .password)

                    forgotPasswordView
                }

                bottomView

                if viewModel.authenticator.userSession != nil || Constants.Security.PresentBioButtonForNoUserSession {
                    if let bioAuth = bioAuth, bioAuth.isAuthSuccessful == nil, bioAuth.biometricType != .none {
                        Button {
                            Task {
                                await bioAuth.requestBiometricAuth { success in
                                    if success {
                                        viewModel.fillCredentialsFromUserSession {
                                            signIn()
                                        }
                                    }
                                }
                            }
                        } label: {
                            Image(systemName: bioAuth.biometricType == .faceID ? "faceid" : "touchid")
                                .resizable()
                                .frame(width: 50, height: 50)
                        }
                    }
                }
            }
        }
        .formNavigationHarness(self, onSubmit: {
            signIn()
        })
        .embedInNavViewWithoutToolbar
        .sheet(isPresented: $shouldShowServerSettings) {

            ServerSettingsView()
        }
        .onAppear {
            animSubmitButtonViewModel.action = {
                signIn()
            }
        }
        .padding(.horizontal)
    }
}

extension SignInView {

    @ViewBuilder
    var serverSettingsButton: some View {
        HStack {

            Spacer()

            Button(action: { shouldShowServerSettings = true }) {

                Text("Server settings")
                    .font(.footnote)
            }
        }
    }

    @ViewBuilder
    var topView: some View {

        VStack {
            Image(systemName: "person.badge.key.fill")
                .resizable()
                .scaledToFit()
                .frame(width: 50, height: 50)

            Text("Sign in")
                .fontWeight(.heavy)
                .font(.title)
        }
    }

    @ViewBuilder
    var forgotPasswordView: some View {

        HStack {

            Spacer()

            Button(action: {

                // TODO: Implement forgot password screen.

            }) {
                Text("Forgot Password?")
                    .foregroundColor(Color.gray.opacity(0.5))
            }
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

            HStack(spacing: 8) {

                Text("Don't Have an Account?")
                    .foregroundColor(Color.gray.opacity(0.5))

                Button(action: {

                    withAnimation {
                        viewModel.moveToSignUp()
                    }
                }) {
                    Text("Sign Up")
                }
                .foregroundColor(.blue)
            }
            .padding(.top, 25)
        }
    }

    func signIn() {

        Task.detached {

            await viewModel.signIn(animSubmitButtonViewModel)

            await MainActor.run {
                resignKeyboard()
            }
        }
    }
}

extension SignInView: FormNavigatableView {

    enum FormField: NavigatableFormFieldEnum {
        case userName, password
    }

    var focusedFieldFocusState: FocusState<FormField?> { _focusedField }
    var focusedFieldFocusStateBinding: FocusState<FormField?>.Binding { $focusedField }
}
