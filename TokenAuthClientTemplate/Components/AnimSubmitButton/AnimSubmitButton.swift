import Combine
import SwiftUI

struct AnimSubmitButton: View {

    @ObservedObject var viewModel: AnimSubmitButtonViewModel

    var body: some View {

        Button(action:
            viewModel.action
        ) {

            HStack {

                Image(systemName: viewModel.systemImage)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 20, height: 20)
                    .foregroundColor(.white)
                    .rotationEffect(.radians(2 * Double.pi * (viewModel.isAnimating ? 1 : 0)))
                    .animation(
                        .linear(duration: 0.75).repeat(while: viewModel.isAnimating, autoreverses: false),
                        value: viewModel.isAnimating
                    )

                Text(!viewModel.isCompleted ? viewModel.labels.initial : viewModel.labels.completed)
                    .foregroundColor(.white)
            }
            .padding(12)
        }
        .background(viewModel.bgColor)
        .clipShape(Capsule())
        .padding(.top, 45)
        .disabled(!viewModel.isActive)
    }
}
