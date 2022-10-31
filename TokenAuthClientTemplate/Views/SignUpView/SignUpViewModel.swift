import Combine
import Foundation
import SwiftUI
import OSLog

@MainActor
final class SignUpViewModel: ObservableObject, Errorable {
    // MARK: - Properties

    let userSessionRepository: UserSessionRepository
    let authenticator: Authenticator
    let moveToSignIn: () -> Void

    @Published var fullname: String = ""
    @Published var username: String = ""
    @Published var password: String = ""
    @Published var passwordAgain: String = ""
    @Published var email: String = ""
    @Published var phone: String = ""

    @Published var fullnameValidity: FieldValidityStatus = .empty
    @Published var usernameValidity: FieldValidityStatus = .empty
    @Published var passwordValidity: FieldValidityStatus = .empty
    @Published var passwordAgainValidity: FieldValidityStatus = .empty
    @Published var emailValidity: FieldValidityStatus = .empty
    @Published var phoneValidity: FieldValidityStatus = .empty

    @Published var fullnameHighlight: FieldHighlight = .none
    @Published var usernameHighlight: FieldHighlight = .none
    @Published var passwordHighlight: FieldHighlight = .none
    @Published var passwordAgainHighlight: FieldHighlight = .none
    @Published var emailHighlight: FieldHighlight = .none
    @Published var phoneHighlight: FieldHighlight = .none

    @Published var isFormValid: Bool = false

    @Published var submitAttempt: Int = 0

    nonisolated let errorPublisher = PassthroughSubject<Error, Never>()

    private var subscriptions = Set<AnyCancellable>()
    private var helpers = [AnyObject]()

    // MARK: - Initialization

    init(userSessionRepository: UserSessionRepository, authenticator: Authenticator, moveToSignIn: @escaping () -> Void) {

        self.userSessionRepository = userSessionRepository
        self.authenticator = authenticator
        self.moveToSignIn = moveToSignIn

        func validateFullname(_ fullname: String) -> FieldValidityStatus {

            let fullname = fullname.trimmingCharacters(in: .whitespacesAndNewlines)

            guard !fullname.isBlank else { return .empty }

            guard fullname.isFullName else { return .invalid }

            return .valid
        }

        func validateUsername(_ username: String) -> AnyPublisher<FieldValidityStatus, Never> {

            let username = username.trimmingCharacters(in: .whitespacesAndNewlines)

            guard !username.isBlank else { return Just(.empty).eraseToAnyPublisher() }

            guard username.isAlphanumeric else { return Just(.invalid).eraseToAnyPublisher() }

            guard username.count >= Constants.Account.MinUsernameLength else { return Just(.insufficient).eraseToAnyPublisher() }

            let accountExistPublisher = Future {
                try await userSessionRepository.accountExists(username: username)
            }
            .catch { error -> AnyPublisher<Bool?, Never> in

                os_log(.error, log: OSLog.default, "[SignUp] Account existance query failed: \(error.localizedDescription)")

                return Just(nil).eraseToAnyPublisher()
            }
            .map { (status: Bool?) -> FieldValidityStatus in
                switch status {
                case true?:
                    return .invalid
                case false?:
                    return .valid
                case nil:
                    return .valid // validate successfully here leaving the responsibility to check duplicates at the stage of submitting a new account
                }
            }
            .prepend([.waiting])
            .eraseToAnyPublisher()

            return accountExistPublisher
        }

        func validatePassword(_ password: String) -> FieldValidityStatus {

            let password = password.trimmingCharacters(in: .whitespacesAndNewlines)

            guard !password.isBlank else { return .empty }

            guard password.isValidPassword else { return .invalid }

            guard password.count >= Constants.Account.MinPasswordLength else { return .insufficient }

            return .valid
        }

        func validateRepeatingPassword(repPass: String, pass: String) -> FieldValidityStatus {

            let repPass = repPass.trimmingCharacters(in: .whitespacesAndNewlines)
            let pass = pass.trimmingCharacters(in: .whitespacesAndNewlines)

            guard !repPass.isBlank else { return .empty }

            if repPass == pass {
                return .valid
            } else {
                return .invalid
            }
        }

        func validateEmail(_ email: String) -> FieldValidityStatus {

            let email = email.trimmingCharacters(in: .whitespacesAndNewlines)

            guard !email.isBlank else { return .empty }

            guard email.isValidEmailAddress else { return .invalid }

            return .valid
        }

        func validatePhone(_ phone: String) -> FieldValidityStatus {

            let phone = phone.trimmingCharacters(in: .whitespacesAndNewlines)

            guard !phone.isBlank else { return .empty }

            guard phone.isValidPhoneNumber else { return .invalid }

            return .valid
        }

        $fullname
            .map { validateFullname($0) }
            .assign(to: \.fullnameValidity, on: self)
            .store(in: &subscriptions)

        $username
//            .debounce(for: 0.5, scheduler: RunLoop.main)
//            .removeDuplicates()
            .map { validateUsername($0) }
            // https://stackoverflow.com/questions/61402122/combine-how-to-cancel-a-flatmaped-publisher#answer-61403996
            .switchToLatest()
            .assign(to: \.usernameValidity, on: self)
            .store(in: &subscriptions)

        $password
            .map { validatePassword($0) }
            .assign(to: \.passwordValidity, on: self)
            .store(in: &subscriptions)

        $passwordAgain
            .combineLatest($password)
            .map { (repPass, pass) -> FieldValidityStatus in
                let passAgainValidity = validateRepeatingPassword(repPass: repPass, pass: pass)
                return passAgainValidity != .valid
                    ? passAgainValidity
                : validatePassword(pass)
            }
            .assign(to: \.passwordAgainValidity, on: self)
            .store(in: &subscriptions)

        $email
            .map { validateEmail($0) }
            .assign(to: \.emailValidity, on: self)
            .store(in: &subscriptions)

        $phone
            .map { validatePhone($0) }
            .assign(to: \.phoneValidity, on: self)
            .store(in: &subscriptions)

        FormFieldHighlighting(
            isRequired: true,
            submitCountProp: \._submitAttempt,
            validityProp: \._fullnameValidity,
            highlightProp: \.fullnameHighlight,
            on: self
        )
        .retain(in: &helpers)

        FormFieldHighlighting(
            isRequired: true,
            submitCountProp: \._submitAttempt,
            validityProp: \._usernameValidity,
            highlightProp: \.usernameHighlight,
            on: self
        )
        .retain(in: &helpers)

        FormFieldHighlighting(
            isRequired: true,
            submitCountProp: \._submitAttempt,
            validityProp: \._passwordValidity,
            highlightProp: \.passwordHighlight,
            on: self
        )
        .retain(in: &helpers)

        FormFieldHighlighting(
            isRequired: true,
            submitCountProp: \._submitAttempt,
            validityProp: \._passwordAgainValidity,
            highlightProp: \.passwordAgainHighlight,
            on: self
        )
        .retain(in: &helpers)

        FormFieldHighlighting(
            isRequired: false,
            submitCountProp: \._submitAttempt,
            validityProp: \._emailValidity,
            highlightProp: \.emailHighlight,
            on: self
        )
        .retain(in: &helpers)

        FormFieldHighlighting(
            isRequired: false,
            submitCountProp: \._submitAttempt,
            validityProp: \._phoneValidity,
            highlightProp: \.phoneHighlight,
            on: self
        )
        .retain(in: &helpers)

        let group1 = $fullnameHighlight.combineLatest($usernameHighlight, $passwordHighlight, $passwordAgainHighlight)
        let group2 = $emailHighlight.combineLatest($phoneHighlight)
        group1.combineLatest(group2)
            .map { gr1, gr2 in
                ![gr1.0, gr1.1, gr1.2, gr1.3,
                  gr2.0, gr2.1]
                    .contains { $0 == .error }
            }
            .assign(to: \.isFormValid, on: self)
            .store(in: &subscriptions)
    }

    // MARK: - API

    func signUp(_ submitButtonReportable: AnimSubmitButtonReportable) async {

        submitAttempt += 1

        guard isFormValid else {
            os_log(.info, log: OSLog.default, "[SignUp] Attempt to submit invalid signup form.")
            submitButtonReportable.signalActionFailure()
            return
        }

        let newAccount = NewAccount(
            fullname: fullname,
            username: username,
            password: password,
            email: email,
            phone: phone
        )

        await authenticator.signIn {
            try await self.userSessionRepository.signUp(newAccount: newAccount)
        }

        if authenticator.status.isAuthenticated ?? false {
            submitButtonReportable.signalActionSuccess()
        } else {
            submitButtonReportable.signalActionFailure()
        }
    }
}
