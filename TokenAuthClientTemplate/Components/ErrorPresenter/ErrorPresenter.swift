import SwiftUI

extension View {

    func errorPresenter(viewModel: ErrorPresenterViewModel) -> some View {
        modifier(ErrorPresenterModifier(viewModel: viewModel))
    }
}

struct ErrorPresenterModifier: ViewModifier {

    @ObservedObject var viewModel: ErrorPresenterViewModel
    @Environment(\.dismiss) var dismiss

    func body(content: Content) -> some View {
        content
            .alert("Error!", isPresented: Binding.constant(viewModel.error != nil)) {
                Button("OK", role: .cancel) {
                    viewModel.error = nil
                    dismiss()
                }
            } message: {
                if let error = viewModel.error {
                    Text(String(describing: error.localizedDescription))
                }
            }
    }
}
