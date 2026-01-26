//
//  HomeFeedViewModel.swift
//  boardGameReview
//
//  Created by Robert Fusting on 1/21/26.
//

import Foundation
import UIKit

class HomeFeedViewModel : ObservableObject {
    @Published var boardGames: [BoardGameModel] = []
    private let boardGameService: BoardGameService
    @Published var LastSeenID: Int = 0
    
    init(boardGameService: BoardGameService = BoardGameService()) {
        self.boardGameService = boardGameService
    }
    
    @MainActor
    func fetchBoardGames(_ userID : Int) async {
        //var url = "http://127.0.0.1:8000/boardGames/user/\(userID)"
        var boardGamesInCache: [BoardGameModel] = []
        //here we first check our cache for existing board games before fetching more from the network
        let feedKeys = BoardGameCache.shared.getFeedKeys()
        
        // if no feed keys just go to network and we are done
        if feedKeys.count == 0 {
            boardGames = await fetchBoardGamesFromNetwork(userID)
        }
        
        //else : we need to check what is in the cache vs what is in our feed keys
        let diff = feedKeys.filter { key in !boardGames.contains(where: { $0.id == key }) }
        
        //if no diff than we are done
        if diff.count != 0 {
            // we do some stuff because if there wasnt a diff we are done
            for i in (0..<(feedKeys.count == 0 ? 25 : feedKeys.count)) {
                let cacheKey = (feedKeys.count == 0 ? 0 : feedKeys[i])
                // we now need to check what is in the cache vs what needs to be fetched from the network according to our feed keys
                if let cachedBoardGame = BoardGameCache.shared.get(id: cacheKey) {
                    boardGamesInCache.append(cachedBoardGame)
                }
                
            }
            let boardGamesToFetch: [Int] = feedKeys.filter { key in !boardGamesInCache.contains(where: { $0.id == key }) }
            
            if boardGamesToFetch.count > 0 {
                let rehydratedBoardGames = try? await boardGameService.rehydrate(userID: userID, boardGameIds: boardGamesToFetch)
                if let rehydratedBoardGames = rehydratedBoardGames {
                    for boardGame in rehydratedBoardGames {
                        BoardGameCache.shared.set(boardGame)
                    }
                    
                    let combinedSorted = (rehydratedBoardGames + boardGamesInCache).sorted { $0.id < $1.id }
                    let diff = combinedSorted.filter { key in !self.boardGames.contains(where: { $0.id == key.id })}
                    self.boardGames += diff
                    self.boardGames = self.boardGames.sorted { $0.id < $1.id }
                }
            }
            
            else {
                let diff = boardGamesInCache.filter { key in !self.boardGames.contains(where: { $0.id == key.id })}
                self.boardGames = (diff + self.boardGames).sorted { $0.id < $1.id }
            }
        }
    }
    
    @MainActor
    func fetchBoardGamesFromNetwork(_ userID: Int) async -> [BoardGameModel] {
        var url = "http://127.0.0.1:8000/boardGames/user/\(userID)"
        let fetchedBoardGames = try? await boardGameService.fetchBoardGameFeedForUser(String(userID), &url, LastSeenID)
        if let fetchedBoardGames = fetchedBoardGames {
            for boardGame in fetchedBoardGames {
                BoardGameCache.shared.set(boardGame)
                BoardGameCache.shared.addFeedKey(boardGame.id)
            }
            self.boardGames.append(contentsOf: fetchedBoardGames)
            LastSeenID += 25
        }
       return boardGames
    }
    
    @MainActor
    func updateImageCache(boardGame: BoardGameModel) async{
        let cachedImage = ImageCache.shared.getImage(for: boardGame.id)
        if cachedImage == nil {
            let networkImage = try? await boardGameService.fetchBoardGameImage(boardGame.image ?? "")
            if let networkImage = networkImage {
                //ID is always valid here because we were able to fetch the image from the network
                ImageCache.shared.storeImage(networkImage, for: boardGame.id)
            }
        }
    }
    
}
    
