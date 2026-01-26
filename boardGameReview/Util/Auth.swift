//
//  Auth.swift
//  boardGameReview
//
//  Created by Robert Fusting on 1/18/26.
//

import Foundation


final class Auth: ObservableObject {
    @Published private(set) var accessToken: String?
    @Published private(set) var refreshToken: String?
    @Published private(set) var tokenType: String?
    @Published private(set) var username: String?
    @Published private(set) var userID: Int?
    
    func setSession(_ auth: AuthResponse) {
        accessToken = auth.access_token
        refreshToken = auth.refresh_token
        tokenType = auth.token_type
        username = auth.user.username
        userID = auth.user.id
        // store refreshToken in Keychain here
    }
    
    func printUsername() {
        print(username ?? "No username set")
    }

    func clear() {
        accessToken = nil
        refreshToken = nil
        tokenType = nil
        username = nil
        userID = nil
        // delete refreshToken from Keychain here
    }
}

