//
//  GameNightFeedView.swift
//  boardGameReview
//
//  Created by Robert Fusting on 3/5/26.
//

import SwiftUI

struct GameNightFeedView: View {
    @EnvironmentObject private var router: AppRouter
    @EnvironmentObject private var auth: Auth
    @StateObject private var gameNightFeedViewModel = GameNightFeedViewModel()
    var body: some View {
        ForEach(gameNightFeedViewModel.gameNights) { gameNight in
            VStack(alignment: .leading, spacing: 8) {
                GameNightCardView
            }
            
            
        }
        Button {
            router.push(.addGameNight(id:1))
        } label : {
            Text("Post game night")
        }
        .onAppear {
            Task {
                await gameNightFeedViewModel.fetchGameNights(userID: auth.userID ?? 1)
            }
        }
    }
}

#Preview {
    GameNightFeedView()
}
