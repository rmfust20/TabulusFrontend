//
//  ReviewModel.swift
//  boardGameReview
//
//  Created by Robert Fusting on 12/6/25.
//

import Foundation

struct ReviewModel: Identifiable, Codable {
    let id: Int?
    let board_game_id: Int
    let user_id: Int
    let username: String
    var rating: Int
    var comment: String?
    var date_created: String?
}
