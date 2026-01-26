import SwiftUI

struct ReviewCardView: View {
    let reviewModel: ReviewModel
    @State var text: String? = nil

    var body: some View {
        HStack(alignment: .top, spacing: 12) {

            Image("userProfile")
                .resizable()
                .scaledToFill()
                .frame(width: 56, height: 56)
                .clipShape(Circle())

            VStack(alignment: .leading, spacing: 6) {

                HStack(spacing: 8) {
                    Text("Robert")
                        .font(.headline)

                    Text("rated it")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)


                    FlexStarsView(rating: .constant(3), size: 13, interactive: false)
                }

                Text(text ?? "this is a sample review i just want to see how it would look with a lot of text and it does not look great")
                    .font(.body)
                    .foregroundStyle(.primary)
                    .fixedSize(horizontal: false, vertical: true) // allows wrapping
            }
        }
        .padding(.vertical, 8)
    }
}

#Preview {
    ReviewCardView(
        reviewModel: ReviewModel(id: 0, board_game_id: 0, user_id: 0, rating: 4, comment: "Great game!")
    )
}

