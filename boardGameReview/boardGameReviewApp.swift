//
//  boardGameReviewApp.swift
//  boardGameReview
//
//  Created by Robert Fusting on 12/6/25.
//

import SwiftUI

@main
struct boardGameReviewApp: App {
    @StateObject private var auth = Auth()
    @StateObject var userViewModel = UserViewModel()
    @StateObject var appRouter = AppRouter()
    var body: some Scene {
        WindowGroup {
            BottomNavBarView()
                .environmentObject(auth)
                .environmentObject(userViewModel)
                .environmentObject(appRouter)
        }
    }
}
