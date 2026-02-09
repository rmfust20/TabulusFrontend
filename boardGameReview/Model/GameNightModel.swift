//
//  GameNightModel.swift
//  boardGameReview
//
//  Created by Robert Fusting on 2/8/26.
//

import Foundation

struct GameNightUploadModel: Codable {
    let host_user_id: Int
    let host_username: String
    let date: String?
    let description: String?
    let images: [String]? // Assuming images are represented as URLs or base64 strings
    let sessions: [GameNightSessionUploadModel]
    let users: [UsersGameNightsModel]?
}

struct GameNightSessionUploadModel: Codable {
    let board_game_id: Int
    let duration_minutes: Int?
    let winner_user_id: Int?
    let description: String?
    let images: [String]? // Assuming images are represented as URLs or base64 strings
    let users: [UsersGameNightsModel]?
}




struct UsersGameNightsModel: Codable {
    let user_id: Int
    let username: String
}

struct GameNightModel : Codable {
    
}


