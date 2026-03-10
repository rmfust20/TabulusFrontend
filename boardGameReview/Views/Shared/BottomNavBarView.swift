//
//  BottomNavBarView.swift
//  boardGameReview
//
//  Created by Robert Fusting on 12/12/25.
//

import SwiftUI

enum Tab: Hashable {
    case home, profile, login, game
}

struct BottomNavBarView: View {
    @State private var selectedTab: Tab = .home
    var body: some View {
        TabView(selection: $selectedTab) {

                AppNavRouter(selectedTab: $selectedTab) { HomeView() }
                .tabItem { Label("Home", systemImage: "house") }
                .tag(Tab.home)

                    NavigationStack {
                        ProfileView(userID: 0)
                    }
                    .tabItem { Label("Profile", systemImage: "person") }
                    .tag(Tab.profile)
            NavigationStack {
                RegisterView(userID: 0)
            }
                    .tabItem {
                        Label("Login", systemImage: "square.and.arrow.up")
                    }
                    .tag(Tab.login)
            
            AppNavRouter(selectedTab: $selectedTab) { GameNightFeedView() }
                .tabItem { Label("Game", systemImage: "calendar") }
                .tag(Tab.game)
                
        }
    }
}

#Preview {
    BottomNavBarView()
}
