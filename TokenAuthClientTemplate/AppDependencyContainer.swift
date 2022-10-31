import Foundation
import MyServerAPI
import SwiftUI

@MainActor
final class AppDependencyContainer {

    // MARK: - Properties

    // Long-lived dependencies:
    let userSessionRepository: UserSessionRepository
    let errorPresenterViewModel: ErrorPresenterViewModel

    let authController: AuthController

    // MARK: - Initialization
    
    init(serverSettings: Binding<ServerSettings>) {

        func makeUserSessionRepository() -> UserSessionRepository {
            let dataStore = makeUserSessionDataStore()
            let remoteAPI = makeRemoteAPI()
            return UserSessionRepositoryAdapter(dataStore: dataStore,
                                                remoteAPI: remoteAPI)
        }

        func makeErrorPresenterViewModel() -> ErrorPresenterViewModel {
            
            ErrorPresenterViewModel()
        }

        func makeUserSessionDataStore() -> UserSessionDataStore {

            let coder = makeUserSessionCoder()
            let storeServerName = String(format: Constants.KeychainStore.serverName, serverSettings.wrappedValue.host)

            return KeychainUserSessionDataStore(userSessionCoder: coder, storeServer: storeServerName)
        }

        func makeUserSessionCoder() -> UserSessionCoding {

            UserSessionPropertyListCoder()
        }

        func makeRemoteAPI() -> MyServerAPI.Client {

            Client(serverSettings: Binding(
                get: { MyServerAPI.ServerSettings(from: serverSettings.wrappedValue) },
                set: { _ in /* noop */ })
            )
        }

        let userSessionRepository = makeUserSessionRepository()
        self.userSessionRepository = userSessionRepository

        let errorPresenterViewModel = makeErrorPresenterViewModel()
        self.errorPresenterViewModel = errorPresenterViewModel

        let authController = AuthController(userSessionRepository: userSessionRepository)
        self.authController = authController
        errorPresenterViewModel.subscribe(authController)
    }

    // MARK: - API

    func makeContentViewModel() -> ContentViewModel {

        ContentViewModel(
            onboardingView: { [unowned self] in
                OnboardingView(
                    viewModel: self.makeOnboardingViewModel())
            },
            homeView: { [unowned self] in
                HomeView(
                    viewModel: self.makeHomeViewModel(),
                    errorPresenterViewModel: self.errorPresenterViewModel)
            })
    }

    func makeOnboardingViewModel() -> OnboardingViewModel {

        let viewModel = OnboardingViewModel()

        viewModel.signUpView = { [unowned self] in
            SignUpView(viewModel: self.makeSignUpViewModel(moveToSignIn: { viewModel.formKind = .signIn }))
        }

        viewModel.signInView = { [unowned self] in
            SignInView(viewModel: self.makeSignInViewModel(moveToSignUp: { viewModel.formKind = .signUp }))
        }

        return viewModel
    }

    func makeSignUpViewModel(moveToSignIn: @escaping () -> Void) -> SignUpViewModel {

        let viewModel = SignUpViewModel(
            userSessionRepository: userSessionRepository,
            authenticator: authController,
            moveToSignIn: moveToSignIn)
        errorPresenterViewModel.subscribe(viewModel)

        return viewModel
    }

    func makeSignInViewModel(moveToSignUp: @escaping () -> Void) -> SignInViewModel {

        let viewModel = SignInViewModel(
            userSessionRepository: userSessionRepository,
            authenticator: authController,
            moveToSignUp: moveToSignUp)
        errorPresenterViewModel.subscribe(viewModel)

        return viewModel
    }

    func makeHomeViewModel() -> HomeViewModel {

        let viewModel = HomeViewModel(
            userSessionRepository: userSessionRepository,
            authenticator: authController,
            cellViewForBook: { [unowned self] in
                BookCellView(viewModel: self.makeBookCellViewModel(for: $0))
            }
        )

        errorPresenterViewModel.subscribe(viewModel)

        return viewModel
    }

    func makeBookCellViewModel(for book: Book) -> BookCellViewModel {

        BookCellViewModel(book: book)
    }

    func contentView() -> ContentView {

        ContentView(
            viewModel: self.makeContentViewModel(),
            authController: self.authController,
            errorPresenterViewModel: self.errorPresenterViewModel)
    }
}
