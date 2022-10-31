import SwiftUI

struct HomeView: View {

    @StateObject var viewModel: HomeViewModel
    @State var signStatus: SignStatus = .signedIn
    @ObservedObject var errorPresenterViewModel: ErrorPresenterViewModel

    var body: some View {

        NavigationView {

            VStack {

                List {
                    ForEach(viewModel.books) { book in
                        viewModel.cellViewForBook(book)
                    }
                }
                .navigationTitle("Home")
                .navigationBarBackButtonHidden(true)
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        HStack(spacing: 0) {

                            Text("Signed in:")
                                .foregroundColor(.primary)

                            if let profile = viewModel.userProfile {
                                Menu {
                                    Picker(selection: $signStatus) {

                                        Text(profile.fullname)
                                            .tag(SignStatus.signedIn)

                                        Text("Sign Out")
                                            .tag(SignStatus.signedOut)
                                    } label: {}
                                } label: {
                                    Text(profile.fullname)
                                        .fontWeight(.medium)
                                        .padding(3)
                                        .background(RoundedRectangle(cornerRadius: 3)
                                            .fill(Color.gray))
                                        .accentColor(.primary)
                                }
                            }
                        }
                    }
                }

                Spacer()
            }
        }
        .searchable(
            text: $viewModel.searchFilter,
            placement: .automatic
        )
        .overlay(
            Group {
                if viewModel.isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        .scaleEffect(2)
                        .allowsHitTesting(false)
                }
            }
        )
        .errorPresenter(viewModel: errorPresenterViewModel)
        .task {
            await viewModel.load()
        }
        .onChange(of: signStatus) { status in
            if status == .signedOut {
                signOut()
            }
        }
    }

    func signOut() {
        
        Task.detached {
            
            await viewModel.signOut()
        }
    }

    enum SignStatus {
        case signedIn, signedOut
    }
}
