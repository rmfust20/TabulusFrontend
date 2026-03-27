//
//  GameNightCardView.swift
//  boardGameReview
//
//  Created by Robert Fusting on 3/8/26.
//

import SwiftUI

struct GameNightCardView: View {
    let gameNight: GameNightModel
    let imageService: ImageService = ImageService()
    let boardGames: [(Int, String)]
    var onDelete: (() -> Void)? = nil
    @EnvironmentObject private var auth: Auth
    @EnvironmentObject private var router: AppRouter
    @State private var gameNightImages: [String] = []
    @State private var profileImageURL: String? = nil
    @State private var hostUsername: String = ""
    @State private var showOptions: Bool = false
    @State private var showDeleteConfirm: Bool = false
    private let userService = UserService()
    private let gameNightService = GameNightService()

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {

            // Header
            HStack(spacing: 12) {
                Group {
                    if let url = profileImageURL {
                        AsyncImage(url: URL(string: url)) { image in
                            image.resizable().scaledToFill()
                        } placeholder: {
                            ProgressView()
                        }
                    } else {
                        Image(systemName: "person.circle.fill")
                            .resizable()
                            .foregroundStyle(Color("MutedText"))
                    }
                }
                .frame(width: 42, height: 42)
                .clipShape(Circle())
                VStack(alignment: .leading, spacing: 2) {
                    Text(hostUsername)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(.white)
                    Text(formattedDate(gameNight.game_night_date))
                        .font(.system(size: 12))
                        .foregroundStyle(Color("MutedText"))
                }
                Spacer()
                Button {
                    showOptions = true
                } label: {
                    Image(systemName: "ellipsis")
                        .foregroundStyle(Color("MutedText"))
                        .padding(.trailing, 4)
                }
                .buttonStyle(.plain)
                .confirmationDialog("", isPresented: $showOptions) {
                    if gameNight.host_user_id == auth.userID {
                        Button("Delete Post", role: .destructive) {
                            showDeleteConfirm = true
                        }
                    } else {
                        Button("Report", role: .destructive) { }
                    }
                    Button("Cancel", role: .cancel) { }
                }
                .alert("Delete Post?", isPresented: $showDeleteConfirm) {
                    Button("Delete", role: .destructive) {
                        Task {
                            try? await gameNightService.deleteGameNight(gameNightID: gameNight.id, accessToken: auth.accessToken ?? "")
                            onDelete?()
                        }
                    }
                    Button("Cancel", role: .cancel) { }
                } message: {
                    Text("This will permanently delete this game night post.")
                }
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 12)

            // Game night photos
            if !gameNightImages.isEmpty {
                if gameNightImages.count == 1, let urlString = gameNightImages.first {
                    AsyncImage(url: URL(string: urlString)) { image in
                        image.resizable().scaledToFill()
                    } placeholder: {
                        Rectangle()
                            .fill(Color.gray.opacity(0.12))
                            .overlay(ProgressView())
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 220)
                    .clipped()
                } else {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            ForEach(gameNightImages, id: \.self) { urlString in
                                AsyncImage(url: URL(string: urlString)) { image in
                                    image.resizable().scaledToFill()
                                } placeholder: {
                                    Rectangle()
                                        .fill(Color.gray.opacity(0.12))
                                        .overlay(ProgressView())
                                }
                                .frame(width: 200, height: 200)
                                .clipped()
                                .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                            }
                        }
                        .padding(.horizontal, 14)
                    }
                }
            }

            // Board games played
            if !boardGames.isEmpty {
                Text("PLAYED")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundStyle(Color("MutedText"))
                    .tracking(1.5)
                    .padding(.horizontal, 14)
                    .padding(.top, 12)

                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(boardGames, id: \.0) { item in
                            Button {
                                router.push(.boardGameDetail(id: item.0))
                            } label: {
                                AsyncImage(url: URL(string: item.1)) { image in
                                    image.resizable().scaledToFill()
                                } placeholder: {
                                    Rectangle()
                                        .fill(Color.gray.opacity(0.12))
                                        .overlay(ProgressView())
                                }
                                .frame(width: 56, height: 56)
                                .clipped()
                                .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                            }
                        }
                    }
                    .padding(.horizontal, 14)
                    .padding(.top, 6)
                }
            }

            // Description
            Text(gameNight.description ?? "")
                .font(.system(size: 14))
                .foregroundStyle(.white.opacity(0.8))
                .multilineTextAlignment(.leading)
                .padding(.horizontal, 14)
                .padding(.top, 10)
                .onAppear {
                    print(boardGames)
                }
        }
        .background(Color("CardSurface"))
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
        .shadow(color: .black.opacity(0.2), radius: 10, x: 0, y: 4)
        .onAppear {
            Task {
                if let images = gameNight.images {
                    let trueImages = try? await imageService.getImageURLs(blobNames: images)
                    if let trueImages = trueImages {
                        gameNightImages = trueImages
                    }
                }
                if let user = try? await userService.getUser(userID: gameNight.host_user_id) {
                    hostUsername = user.username ?? "Loading"
                    if let blobName = user.profile_image_url {
                        profileImageURL = try? await imageService.getImageURL(blobName: blobName)
                    }
                }
            }
        }
    }

    private func formattedDate(_ dateString: String) -> String {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        if let date = formatter.date(from: dateString) {
            return DateFormatter.localizedString(from: date, dateStyle: .medium, timeStyle: .none)
        }
        formatter.formatOptions = [.withInternetDateTime]
        if let date = formatter.date(from: dateString) {
            return DateFormatter.localizedString(from: date, dateStyle: .medium, timeStyle: .none)
        }
        return dateString
    }
}

#Preview {
    GameNightCardView(
        gameNight: GameNightModel(
            id: 0,
            host_user_id: 0,
            game_night_date: "2024-05-09T19:00:00Z",
            description: "Had a great time playing Catan with friends!",
            sessions: [
                GameNightSessionModel(board_game_id: 181, duration_minutes: 90, winners_user_id: [1, 2]),
            ],
            images: ["https://www.moongiant.com/images/todays_moon_phase.jpg", "https://upload.wikimedia.org/wikipedia/commons/1/10/Supermoon_Nov-14-2016-minneapolis.jpg", "https://media.wired.com/photos/5c425dd1ce277c2cb23d5667/master/pass/Blood-Moon-586081787.jpg"],
            users: []
        ), boardGames: [(181, "https://cf.geekdo-images.com/Oem1TTtSgxOghRFCoyWRPw__original/img/Nu3eXPyOkhtnR3hhpUrtgqRMAfs=/0x0/filters:format(jpeg)/pic4916782.jpg")]
    )
}
