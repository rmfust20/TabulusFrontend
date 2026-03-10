//
//  GameNightFeedViewModel.swift
//  boardGameReview
//
//  Created by Robert Fusting on 3/7/26.
//

import Foundation

class GameNightFeedViewModel: ObservableObject {
    private let gameNightService : GameNightService
    @Published var gameNights: [GameNightModel] = []
    
    
    init(gameNightService: GameNightService = GameNightService()) {
        self.gameNightService = gameNightService
    }
    
    @MainActor
    func fetchGameNights(userID: Int) async {
        let nights =  try? await gameNightService.getGameNightFeed(userID: userID)
        
        if let nights = nights {
            self.gameNights = nights
        }
    }
}
