//
//  HomeNavRootView.swift
//  boardGameReview
//
//  Created by Robert Fusting on 12/13/25.
//

import SwiftUI

enum HomeRoute: Hashable {
    case userProfile(id: Int)
    case boardGame(id: Int)
    case addReview(id: Int, rating : Int?)
    case login(id: Int)
}

struct HomeNavRootView: View {
    @Binding var selectedTab: Tab
    @StateObject private var router = HomeRouter()

    var body: some View {
        NavigationStack(path: $router.path) {
            HomeView()
                .environmentObject(router)
                // This ensures the back button doesn't carry the "Home" text forward
                .navigationDestination(for: HomeRoute.self) { route in
                    viewForRoute(route)
                        .customNavBar(trailingTitle: trailingTitle(for: route))
                        // This removes the "Back" text and keeps only the arrow
                }
        }
        .environmentObject(router)
    }
    @ViewBuilder
    private func viewForRoute(_ route: HomeRoute) -> some View {
        switch route {
        case .userProfile(let id):
            ProfileView(userID: id)
        case .boardGame(let id):
            BoardGameView(boardGameID: id)
        case .addReview(let id, let rating):
            AddReviewView(boardGameID: id, rating: rating ?? 0)
        case .login(let id):
            RegisterView(userID: id)
        }
    }
}

private func trailingTitle(for route: HomeRoute) -> Bool {
    switch route {
    case .addReview:
        return true
    default:
        return false
    }
}
