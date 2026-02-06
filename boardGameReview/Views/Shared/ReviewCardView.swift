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
                    Text(reviewModel.username)
                        .font(.headline)

                    Text("rated it")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)


                    FlexStarsView(rating:.constant( reviewModel.rating), size: 13, interactive: false)
                }

                Text(reviewModel.comment ?? "")
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
        reviewModel: ReviewModel(id: 0, board_game_id: 0, user_id: 0, username: "rmfust50", rating: 4, comment: "Great game!")
    )
}

