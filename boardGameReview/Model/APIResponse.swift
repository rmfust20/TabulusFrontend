//
//  APIResponse.swift
//  boardGameReview
//
//  Created by Robert Fusting on 12/6/25.
//

import Foundation

struct APIResponse: Codable {
    let AuthResponse: AuthResponse
    let RegisterResponse: RegisterResponse
}

struct AuthResponse: Codable {
    let access_token: String
    let refresh_token: String
    let token_type: String
    let user: RegisterResponse
}

struct RegisterResponse: Codable {
    let username: String
    let id : Int
}
