import SwiftUI

struct BookCellView: View {

    let viewModel: BookCellViewModel

    var body: some View {

        VStack(alignment: .leading) {

            Text(viewModel.title)
                .font(.headline)
                .foregroundColor(.primary)

            HStack(alignment: .top) {

                Text("Author: ")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                +
                Text(viewModel.author)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .italic()
            }

            HStack(alignment: .top) {
                Text("Genres: ")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                +
                Text(viewModel.genres)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .italic()
            }
        }
    }
}
