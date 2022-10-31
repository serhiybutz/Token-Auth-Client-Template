import Combine
import Foundation

@MainActor
final class HomeViewModel: ObservableObject, Errorable, TrackLoadingTrait {
    // MARK: - Properties

    let userSessionRepository: UserSessionRepository
    let authenticator: Authenticator

    let cellViewForBook: (Book) -> BookCellView

    @Published var searchFilter: String = ""
    @Published var books: [Book] = []

    nonisolated let errorPublisher = PassthroughSubject<Error, Never>()

    @Published var isLoading = false

    var userProfile: UserProfile? {
        authenticator.userSession?.userProfile
    }

    var remoteUserSession: RemoteUserSession? {
        authenticator.userSession?.remoteUserSession
    }

    private var subscriptions: Set<AnyCancellable> = []

    // MARK: - Initialization

    init(userSessionRepository: UserSessionRepository,
         authenticator: Authenticator,
         cellViewForBook: @escaping (Book) -> BookCellView)
    {
        self.userSessionRepository = userSessionRepository
        self.authenticator = authenticator
        self.cellViewForBook = cellViewForBook

        $searchFilter
            .dropFirst() // we don't need the current value, which is published on subscription
            .map { (filter) -> String? in
                let result = filter.trimmingCharacters(in: .whitespacesAndNewlines)
                return result.isBlank ? nil : result
            }
            .removeDuplicates()
            .debounce(for: 0.3, scheduler: DispatchQueue.main)
            .sink(receiveValue: { filter in
                Task.detached {
                    await self.loadBooks(filter)
                }
            })
            .store(in: &subscriptions)
    }

    // MARK: - API

    func load() async {

        Task.detached {

            await self.loadBooks()
        }
    }

    func loadBooks(_ filter: String? = nil) async {

        await self.trackLoading {

            do {
                let books = try await self.userSessionRepository.getBooks(
                    with: .init(
                        filter: filter,
                        sortField: .title),
                    remoteUserSession!)

                await MainActor.run {
                    self.books = books
                }
            } catch {

                self.errorPublisher.send(error)
                return
            }
        }
    }

    func signOut() async {

        await authenticator.signOut()
        books.removeAll()
    }
}
