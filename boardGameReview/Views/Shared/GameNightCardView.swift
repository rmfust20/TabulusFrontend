//
//  GameNightCardView.swift
//  boardGameReview
//
//  Created by Robert Fusting on 3/8/26.
//

import SwiftUI

struct GameNightCardView: View {
    let gameNight: GameNightFeedModel
    let onEllipsisTap: () -> Void
    @EnvironmentObject private var router: AppRouter
    @State private var isDescriptionExpanded = false
    @State private var isDescriptionTruncated = false
    @State private var fullDescriptionHeight: CGFloat? = nil
    @State private var clampedDescriptionHeight: CGFloat? = nil
    private let descriptionCollapsedLineLimit = 3

    private var nonHostPlayers: [PlayerFeedModel] {
        gameNight.players.filter { $0.id != gameNight.hostUserID }
    }

    private var hostIsWinner: Bool {
        gameNight.players.first { $0.id == gameNight.hostUserID }?.isWinner ?? false
    }

    private var boardGames: [(id: Int, imageURL: String)] {
        var seen = Set<Int>()
        return gameNight.sessions.compactMap { session in
            guard seen.insert(session.board_game.id).inserted,
                  let image = session.board_game.image else { return nil }
            return (session.board_game.id, image)
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {

            // Header
            HStack(spacing: 12) {
                ZStack(alignment: .bottom) {
                    Button {
                        router.push(.profile(id: gameNight.hostUserID, username: gameNight.hostUsername))
                    } label: {
                        Group {
                            if let url = gameNight.hostProfileImageURL {
                                RetryAsyncImage(url: URL(string: url), context: .profiles) { image in
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
                        .overlay(
                            Circle().stroke(hostIsWinner ? Color.yellow : Color.clear, lineWidth: 2.5)
                        )
                    }

                    if hostIsWinner {
                        Text("Winner")
                            .font(.system(size: 7, weight: .bold))
                            .foregroundStyle(.black)
                            .padding(.horizontal, 4)
                            .padding(.vertical, 2)
                            .background(Color.yellow)
                            .clipShape(Capsule())
                            .offset(y: 8)
                    }
                }
                .padding(.bottom, hostIsWinner ? 8 : 0)
                VStack(alignment: .leading, spacing: 2) {
                    Button {
                        router.push(.profile(id: gameNight.hostUserID, username: gameNight.hostUsername))
                    } label: {
                        Text(gameNight.hostUsername)
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundStyle(.white)
                    }.buttonStyle(.plain)
                    Text(formattedDate(gameNight.date))
                        .font(.system(size: 12))
                        .foregroundStyle(Color("MutedText"))
                }
                Spacer()
                Button {
                    onEllipsisTap()
                } label: {
                    Image(systemName: "ellipsis")
                        .foregroundStyle(Color("MutedText"))
                        .frame(width: 44, height: 44, alignment: .trailing)
                        .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 12)

            // Game night photos
            if !gameNight.photos.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(gameNight.photos, id: \.self) { urlString in
                            RetryAsyncImage(url: URL(string: urlString), context: .gameNights) { image in
                                image.resizable().scaledToFill()
                            } placeholder: {
                                Rectangle()
                                    .fill(Color.gray.opacity(0.12))
                                    .overlay(ProgressView())
                            }
                            .frame(width: 300, height: 300)
                            .clipped()
                            .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                        }
                    }
                    .padding(.horizontal, 14)
                }
            }

            // Players
            // Board games played
            if !boardGames.isEmpty {
                
                Text("Played")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundStyle(Color("MutedText"))
                    .tracking(1.5)
                    .padding(.horizontal, 14)
                    .padding(.top, 12)
                

                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(boardGames, id: \.id) { item in
                            Button {
                                router.push(.boardGame(id: item.id))
                            } label: {
                                RetryAsyncImage(url: URL(string: item.imageURL), context: .default) { image in
                                    image.resizable().scaledToFill()
                                } placeholder: {
                                    Rectangle()
                                        .fill(Color.gray.opacity(0.12))
                                        .overlay(ProgressView())
                                }
                                .frame(width: gameNight.photos.isEmpty ? 170 : 130, height: gameNight.photos.isEmpty ? 170 : 130)
                                .clipped()
                                .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                            }
                        }
                    }
                    .padding(.horizontal, 14)
                    .padding(.top, 6)
                }
            }
        
            
            if !nonHostPlayers.isEmpty {
                Text("Players")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundStyle(Color("MutedText"))
                    .tracking(1.5)
                    .padding(.horizontal, 14)
                    .padding(.top, 12)
                

                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 14) {
                        ForEach(nonHostPlayers) { player in
                            Button {
                                router.push(.profile(id: player.id, username: player.username))
                            } label: {
                                ZStack(alignment: .bottom) {
                                    Group {
                                        if let url = player.profileImageURL {
                                            RetryAsyncImage(url: URL(string: url), context: .profiles) { image in
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
                                    .frame(width: 44, height: 44)
                                    .clipShape(Circle())
                                    .overlay(
                                        Circle().stroke(player.isWinner ? Color.yellow : Color.clear, lineWidth: 2.5)
                                    )

                                    if player.isWinner {
                                        Text("Winner")
                                            .font(.system(size: 7, weight: .bold))
                                            .foregroundStyle(.black)
                                            .padding(.horizontal, 4)
                                            .padding(.vertical, 2)
                                            .background(Color.yellow)
                                            .clipShape(Capsule())
                                            .offset(y: 8)
                                    }
                                }
                                .padding(.bottom, player.isWinner ? 8 : 0)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.horizontal, 14)
                    .padding(.top, 6)
                }
            }

            // Description
            if let description = gameNight.description, !description.isEmpty {
                Rectangle()
                    .fill(Color("MutedText").opacity(0.30))
                    .frame(height: 1)
                    .padding(.vertical, 12)
                VStack(alignment: .leading, spacing: 6) {
                    Text(description)
                        .font(.system(size: 14))
                        .foregroundStyle(.white.opacity(0.8))
                        .multilineTextAlignment(.leading)
                        .lineLimit(isDescriptionExpanded ? nil : descriptionCollapsedLineLimit)
                        .fixedSize(horizontal: false, vertical: true)
                        .background(
                            Text(description)
                                .font(.system(size: 14))
                                .fixedSize(horizontal: false, vertical: true)
                                .hidden()
                                .background(GeometryReader { full in
                                    Color.clear.preference(
                                        key: GameNightDescFullHeightKey.self,
                                        value: full.size.height
                                    )
                                })
                        )
                        .background(
                            Text(description)
                                .font(.system(size: 14))
                                .lineLimit(descriptionCollapsedLineLimit)
                                .fixedSize(horizontal: false, vertical: true)
                                .hidden()
                                .background(GeometryReader { clamped in
                                    Color.clear.preference(
                                        key: GameNightDescClampedHeightKey.self,
                                        value: clamped.size.height
                                    )
                                })
                        )
                        .onPreferenceChange(GameNightDescFullHeightKey.self) { fullHeight in
                            evaluateDescriptionTruncation(fullHeight: fullHeight, clampedHeight: nil)
                        }
                        .onPreferenceChange(GameNightDescClampedHeightKey.self) { clampedHeight in
                            evaluateDescriptionTruncation(fullHeight: nil, clampedHeight: clampedHeight)
                        }

                    if isDescriptionTruncated {
                        Button {
                            isDescriptionExpanded.toggle()
                        } label: {
                            Text(isDescriptionExpanded ? "See less" : "See more")
                                .font(.system(size: 13, weight: .semibold))
                                .foregroundStyle(Color("MutedText"))
                        }
                    }
                }
                .padding(.horizontal, 14)
                .padding(.top, 10)
            }
        }
        .padding(.bottom,14)
        .background(Color("CardSurface").opacity(0.2))
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
        .shadow(color: .black.opacity(0.2), radius: 10, x: 0, y: 4)
    }

    private func evaluateDescriptionTruncation(fullHeight: CGFloat?, clampedHeight: CGFloat?) {
        if let full = fullHeight {
            fullDescriptionHeight = full
        }
        if let clamped = clampedHeight {
            clampedDescriptionHeight = clamped
        }
        guard let full = fullDescriptionHeight, let clamped = clampedDescriptionHeight else { return }
        let shouldTruncate = full > clamped + 0.5
        if shouldTruncate != isDescriptionTruncated {
            isDescriptionTruncated = shouldTruncate
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

enum GameNightCardAlert {
    case report(GameNightFeedModel)
    case block(GameNightFeedModel)
    case deleteConfirm(GameNightFeedModel)
    case deleteError
    case reportSuccess
    case blockSuccess(String)
}

struct GameNightCardActionsModifier: ViewModifier {
    @Binding var optionsTarget: GameNightFeedModel?
    @Binding var activeAlert: GameNightCardAlert?
    let viewerUserID: Int?
    let accessToken: String
    let onDeleted: (Int) -> Void
    let onBlocked: () -> Void
    let onReported: () -> Void

    private let gameNightService = GameNightService()
    private let userService = UserService()

    func body(content: Content) -> some View {
        content
            .confirmationDialog(
                "",
                isPresented: Binding(
                    get: { optionsTarget != nil },
                    set: { if !$0 { optionsTarget = nil } }
                ),
                presenting: optionsTarget
            ) { target in
                if target.hostUserID == viewerUserID {
                    Button("Delete Post", role: .destructive) {
                        activeAlert = .deleteConfirm(target)
                    }
                } else {
                    Button("Report", role: .destructive) {
                        activeAlert = .report(target)
                    }
                    Button("Block", role: .destructive) {
                        activeAlert = .block(target)
                    }
                }
                Button("Cancel", role: .cancel) { }
            }
            .alert(
                alertTitle,
                isPresented: Binding(
                    get: { activeAlert != nil },
                    set: { if !$0 { activeAlert = nil } }
                ),
                presenting: activeAlert
            ) { alert in
                alertActions(for: alert)
            } message: { alert in
                alertMessage(for: alert)
            }
    }

    private var alertTitle: String {
        switch activeAlert {
        case .report: return "Report this post?"
        case .block(let night): return "Block \(night.hostUsername)?"
        case .deleteConfirm: return "Delete Post?"
        case .deleteError: return "Delete Failed"
        case .reportSuccess: return "Reported"
        case .blockSuccess(let name): return "Blocked \(name)"
        case .none: return ""
        }
    }

    @ViewBuilder
    private func alertActions(for alert: GameNightCardAlert) -> some View {
        switch alert {
        case .report(let night):
            Button("Report", role: .destructive) {
                Task {
                    try? await gameNightService.reportGameNight(gameNightID: night.id, accessToken: accessToken)
                    onReported()
                    activeAlert = .reportSuccess
                }
            }
            Button("Cancel", role: .cancel) { }
        case .block(let night):
            Button("Block", role: .destructive) {
                Task {
                    try? await userService.blockUser(userID: night.hostUserID, accessToken: accessToken)
                    onBlocked()
                    activeAlert = .blockSuccess(night.hostUsername)
                }
            }
            Button("Cancel", role: .cancel) { }
        case .deleteConfirm(let night):
            Button("Delete", role: .destructive) {
                Task {
                    do {
                        try await gameNightService.deleteGameNight(gameNightID: night.id, accessToken: accessToken)
                        onDeleted(night.id)
                    } catch {
                        activeAlert = .deleteError
                    }
                }
            }
            Button("Cancel", role: .cancel) { }
        case .deleteError, .reportSuccess, .blockSuccess:
            Button("OK", role: .cancel) { }
        }
    }

    @ViewBuilder
    private func alertMessage(for alert: GameNightCardAlert) -> some View {
        switch alert {
        case .report:
            Text("This post will be reported for review.")
        case .block:
            Text("You won't see their reviews or game nights anymore.")
        case .deleteConfirm:
            Text("This will permanently delete this game night post.")
        case .deleteError:
            Text("Failed to delete this post. Please try again.")
        case .reportSuccess:
            Text("Thanks for reporting. We'll review this post.")
        case .blockSuccess:
            Text("You won't see their reviews or game nights anymore.")
        }
    }
}

extension View {
    func gameNightCardActions(
        optionsTarget: Binding<GameNightFeedModel?>,
        activeAlert: Binding<GameNightCardAlert?>,
        viewerUserID: Int?,
        accessToken: String,
        onDeleted: @escaping (Int) -> Void,
        onBlocked: @escaping () -> Void,
        onReported: @escaping () -> Void
    ) -> some View {
        modifier(GameNightCardActionsModifier(
            optionsTarget: optionsTarget,
            activeAlert: activeAlert,
            viewerUserID: viewerUserID,
            accessToken: accessToken,
            onDeleted: onDeleted,
            onBlocked: onBlocked,
            onReported: onReported
        ))
    }
}

private struct GameNightDescFullHeightKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = max(value, nextValue())
    }
}

private struct GameNightDescClampedHeightKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = max(value, nextValue())
    }
}

#Preview {
    GameNightCardView(
        gameNight: GameNightFeedModel(
            id: 0,
            hostUserID: 0,
            hostUsername: "previewUser",
            hostProfileImageURL: nil as String?,
            date: "2024-05-09T19:00:00Z",
            description: "I wanna be yours - arctic monkeys",
            photos: [],
            players: [
                PlayerFeedModel(id: 1, username: "alice", profileImageURL: nil, isWinner: true),
                PlayerFeedModel(id: 2, username: "bob", profileImageURL: nil, isWinner: false)
            ],
            sessions: [
                GameNightSessionModel(
                    board_game: BoardGameModel(
                        id: 181,
                        name: "Catan",
                        thumbnail: nil,
                        play_time: 90,
                        min_players: 3,
                        max_players: 4,
                        year_published: 1995,
                        description: nil,
                        min_age: 10,
                        image: "https://cf.geekdo-images.com/Oem1TTtSgxOghRFCoyWRPw__original/img/Nu3eXPyOkhtnR3hhpUrtgqRMAfs=/0x0/filters:format(jpeg)/pic4916782.jpg"
                    ),
                    duration_minutes: 90,
                    winners_user_id: [1]
                )
            ]
        ),
        onEllipsisTap: {}
    )
    .environmentObject(AppRouter())
    .padding()
    .background(Color("CharcoalBackground"))
}
