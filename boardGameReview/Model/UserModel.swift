//
//  UserModel.swift
//  boardGameReview
//
//  Created by Robert Fusting on 12/6/25.
//

import Foundation

struct UserModel: Identifiable, Codable {
    let id: Int?
    let username: String
    let email: String
    var password: String
}
