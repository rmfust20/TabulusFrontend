//
//  ReviewViewModel.swift
//  boardGameReview
//
//  Created by Robert Fusting on 1/7/26.
//

import Foundation

class ReviewViewModel : ObservableObject {
    let reviewService: ReviewService
    var boardGameID: Int = 0 // Replace with actual board game ID as needed
    var userID: Int = 0 // Replace with actual user ID as needed
    var review: ReviewModel? = nil
    
    init(reviewService: ReviewService = ReviewService()) {
        self.reviewService = reviewService
    }
    
    func postReview(_ review: ReviewModel, accessToken: String) async throws {
        try await reviewService.postReview(review: review, accessToken: accessToken)
    }
}
