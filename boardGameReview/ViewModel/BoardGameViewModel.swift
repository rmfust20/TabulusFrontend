//
//  BoardGameViewModel.swift
//  boardGameReview
//
//  Created by Robert Fusting on 12/7/25.
//

import Foundation
import UIKit

class BoardGameViewModel: ObservableObject {
    private let boardGameService: BoardGameService
    let boardGameID: Int
    @Published var boardGame : BoardGameModel? = nil
    @Published var LastSeenID: Int = 0
    @Published var boardGameImage : UIImage? = nil
    @Published var reviews: [ReviewModel] = []
    @Published var averageRating: Double? = nil
    @Published var numberOfRatings: Int? = nil
    @Published var numberOfReviews: Int? = nil
    @Published var userRating : Int = 0
    private let reviewService: ReviewService
    
    init(boardGameService: BoardGameService = BoardGameService(), reviewService: ReviewService = ReviewService(), boardGameID: Int) {
        self.boardGameService = boardGameService
        self.reviewService = reviewService
        self.boardGameID = boardGameID
    }
    
    func fetchBoardGame(_ boardGameID : Int) async -> BoardGameModel? {
        let url = "http://127.0.0.1:8000/boardGames/boardGame/\(boardGameID)"
        let fetchedBoardGame = try? await boardGameService.fetchBoardGame(url)
        if let fetchedBoardGame = fetchedBoardGame {
            return fetchedBoardGame
        }
        else {
            return nil
        }
    }
    
    @MainActor
    func presentImage() async {
        let cachedImage = ImageCache.shared.getImage(for: boardGame?.id ?? 0)
        if cachedImage == nil {
            let networkImage = try? await boardGameService.fetchBoardGameImage(boardGame?.image ?? "")
            if let networkImage = networkImage {
                //ID is always valid here because we were able to fetch the image from the network
                ImageCache.shared.storeImage(networkImage, for: boardGame!.id)
                self.boardGameImage = networkImage
            }
        }
        else {
            self.boardGameImage = cachedImage
        }
    }
    
    @MainActor
    func presentBoardGame() async {
        let cachedBoardGame = BoardGameCache.shared.get(id: boardGameID)
        if cachedBoardGame == nil {
            let networkBoardGame = await fetchBoardGame(boardGameID)
            if let networkBoardGame = networkBoardGame {
                BoardGameCache.shared.set(networkBoardGame)
                self.boardGame = networkBoardGame
            }
        }
        else {
            self.boardGame = cachedBoardGame
        }
    }
    
    @MainActor
    func getBoardGameDesigners() async -> [String] {
        let designers = try? await boardGameService.fetchBoardGameDesigners(boardGameID)
        return designers ?? []
    }
    
    @MainActor
    func getReviews() async {
        if let fetchedReviews = try? await reviewService.getReviews(boardGameID: boardGameID) {
            reviews = fetchedReviews
        }
    }
    
    @MainActor
    func getReviewStats(boardGameID : Int) async {
        if let stats = try? await reviewService.getReviewStats(boardGameID: boardGameID) {
            averageRating = stats.average_rating
            numberOfRatings = stats.number_of_ratings
            numberOfReviews = stats.number_of_reviews
        }
    }
    
    @MainActor
    func getUserReview(userID: Int) async {
        if let review = try? await reviewService.getUserReview(boardGameID: boardGameID, userID: userID) {
            userRating = review.rating
        }
    }
}
