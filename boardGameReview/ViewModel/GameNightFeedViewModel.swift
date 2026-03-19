//
//  GameNightFeedViewModel.swift
//  boardGameReview
//
//  Created by Robert Fusting on 3/7/26.
//

import Foundation

class GameNightFeedViewModel: ObservableObject {
    private let gameNightService : GameNightService
    private let boardGameSerivce: BoardGameService
    private let imageService: ImageService
    @Published var gameNights: [GameNightModel] = []
    @Published var boardGames: [Int: String] = [:]
    @Published var imageURLs: [Int:String] = [:]
    
    
    
    init(gameNightService: GameNightService = GameNightService(), boardGameSerivce: BoardGameService = BoardGameService(), imageService: ImageService = ImageService()) {
        self.gameNightService = gameNightService
        self.boardGameSerivce = boardGameSerivce
        self.imageService = imageService
    }
    
    @MainActor
    func fetchGameNights(userID: Int) async {
        let nights =  try? await gameNightService.getGameNightFeed(userID: userID)
        
        if let nights = nights {
            self.gameNights = nights
        }
    }
    
    @MainActor
    func fetchBoardGameDetails() async {
        
        var boardGameIDS: [Int] = []
        
        for night in gameNights {
            for bgSession in night.sessions {
                boardGameIDS.append(bgSession.board_game_id)
            }
        }
        
        
        let boardGames = try? await boardGameSerivce.fetchBoardGamesByIds(ids: boardGameIDS)
        
        if let boardGames = boardGames {
            for game in boardGames {
                self.boardGames[game.id] = game.image ?? game.name
            }
        }
    }
    
    @MainActor
    func fetchImageURLFromBlob(id : Int, blobNames : [String?]) async {
        var blobFinal : [String] = []
        for blobName in blobNames {
            if let blobName = blobName {
                blobFinal.append(blobName)
            }
        }
        let imageURLs = try? await imageService.getImageURLs(blobNames: blobFinal)
        for url in imageURLs ?? [] {
            self.imageURLs[id]?.append(url)
        }
    }
    
    @MainActor
    func fetchUserGameNights(userID: Int) async {
        let nights = try? await gameNightService.getUserGameNights(userID: userID)

        if let nights {
            self.gameNights = nights
        }
    }
}
