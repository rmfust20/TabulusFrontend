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
    let userOnly: Bool
    var body: some View {
        ScrollView {
            ZStack {
                Color("SoftOffWhite")
                VStack {
                    ForEach(gameNightFeedViewModel.gameNights) { gameNight in
                        GameNightCardView(
                            gameNight: gameNight,
                            boardGames: gameNightFeedViewModel.boardGames
                                .filter { gameNight.sessions.map { $0.board_game_id }.contains($0.key) }
                                .map { ($0.key, $0.value) }
                        )
                        Rectangle()
                            .fill(Color.gray.opacity(0.4))
                            .frame(maxWidth: .infinity, maxHeight: 1)
                            .padding(.horizontal)
                    }
                    Button {
                        router.push(.addGameNight(id:1))
                    } label : {
                        Text("Post game night")
                    }
                    .onAppear {
                        Task {
                            if userOnly == true {
                                await gameNightFeedViewModel.fetchUserGameNights(userID: auth.userID ?? 1)
                            } else {
                                await gameNightFeedViewModel.fetchGameNights(userID: auth.userID ?? 1)
                            }
                            async let boardGames: () = gameNightFeedViewModel.fetchBoardGameDetails()
                            async let imageURLs: () = {
                                await withTaskGroup(of: Void.self) { group in
                                    for gameNight in await gameNightFeedViewModel.gameNights {
                                        let id = gameNight.id
                                        let blobNames = gameNight.images ?? []
                                        group.addTask {
                                            await gameNightFeedViewModel.fetchImageURLFromBlob(id: id, blobNames: blobNames)
                                        }
                                    }
                                }
                            }()
                            await boardGames
                            await imageURLs
                        }
                    }
                }
            }
        }
    }
}

#Preview {
      let auth = Auth()
      auth.setSession(AuthResponse(
          access_token: "preview-token",
          refresh_token: "preview-refresh",
          token_type: "bearer",
          user: RegisterResponse(username: "previewUser", id: 2)
      ))
    return GameNightFeedView(userOnly: false)
          .environmentObject(auth)
          .environmentObject(AppRouter())
  }
