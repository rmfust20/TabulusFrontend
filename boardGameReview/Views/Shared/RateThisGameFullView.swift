import SwiftUI

struct RateThisGameFullView: View {
    @EnvironmentObject private var router: HomeRouter// 0 means “no rating yet”
    @StateObject private var reviewViewModel = ReviewViewModel()
    @EnvironmentObject private var auth : Auth
    let id : Int
    @Binding var rating: Int

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Rate This Game:")
                .foregroundStyle(.gray)
            FlexStarsView(rating:$rating, size: 24, interactive: true)
        }
        .padding()
        .onDisappear{
            if rating > 0 {
                Task {
                    let reviewModel = ReviewModel(
                        id: nil,
                        board_game_id: id,
                        user_id: auth.userID ?? 0,
                        username: auth.username ?? "unknown",
                        rating: rating,
                        comment: nil
                    )
                    do {
                        try await reviewViewModel.postReview(reviewModel, accessToken: auth.accessToken ?? "")
                    }
                    catch {
                        print("Error posting review: \(error)")
                    }
                }
            }
        }
        
        if rating > 0 {
            ReviewButton(id: id, rating: rating)
        }
           
    }
    
}

struct Stars : View {
    @Binding var rating: Int
    var body: some View {
        HStack(spacing: 8) {
            ForEach(0..<5) { index in
                Button {
                    let newRating = index + 1
                    rating = (rating == newRating) ? 0 : newRating
                    //TODO network call to update users ratings
                } label: {
                    Image(systemName: index < rating ? "star.fill" : "star")
                        .font(.title)
                        .foregroundStyle(index < rating ? .yellow : .gray)
                }
                .buttonStyle(.plain)
                .accessibilityLabel("Rate \(index + 1) star\(index == 0 ? "" : "s")")
            }
        }
    }
}

#Preview {
    RateThisGameFullView(id: 1, rating: .constant(2))
}

