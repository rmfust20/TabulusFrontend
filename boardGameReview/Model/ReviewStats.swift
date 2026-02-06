//
//  ReviewStats.swift
//  boardGameReview
//
//  Created by Robert Fusting on 1/27/26.
//

import Foundation

struct ReviewStatsModel: Codable {
    let average_rating: Double
    let number_of_ratings: Int
    let number_of_reviews: Int
}
