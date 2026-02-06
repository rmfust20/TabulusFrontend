//
//  UserViewModel.swift
//  boardGameReview
//
//  Created by Robert Fusting on 1/18/26.
//

import Foundation

class UserViewModel: ObservableObject {
    var userService = UserService()
    
    func register(username: String, email: String, password: String, authStore : Auth) async {
        let user = UserModel(id: nil, username: username, email: email, password: password)
        let creds = try? await userService.registerUser(user: user)
        
        if creds != nil {
            var accessResponse = try? await userService.login(username: username, password: password)
            if let accessResponse = accessResponse {
                await populateAuth(auth: accessResponse, authStore: authStore )
            }
        }
    }
    
    func login(username: String, password: String, authStore: Auth) async {
        let accessResponse = try? await userService.login(username: username, password: password)
        if let accessResponse = accessResponse {
            await populateAuth(auth: accessResponse, authStore: authStore)
        }
    }
    
    @MainActor
    func populateAuth(auth: AuthResponse, authStore: Auth) {
        authStore.setSession(auth)
    }
    
    
}
