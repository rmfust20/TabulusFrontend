//
//  GameNightViewModel.swift
//  boardGameReview
//
//  Created by Robert Fusting on 2/9/26.
//
import Foundation

class GameNightViewModel: ObservableObject {
    
    private let boardGameService: BoardGameService
    private let gameNightService: GameNightService
    @Published var selectedGames: [BoardGameModel] = []
    @Published var userFriends: [UserPublicModel] = []
    @Published var filteredFriends: [UserPublicModel] = []
    @Published var selectedFriends: [UserPublicModel] = []
    
    init(boardGameService: BoardGameService = BoardGameService(), gameNightService: GameNightService = GameNightService()) {
        self.boardGameService = boardGameService
        self.gameNightService = gameNightService
    }
    
    @MainActor
    func fetchBoardGame(_ boardGameID : Int) async -> BoardGameModel? {
        let fetchedBoardGame = try? await boardGameService.fetchBoardGame(boardGameID: boardGameID)
        if let fetchedBoardGame = fetchedBoardGame {
            return fetchedBoardGame
        }
        else {
            return nil
        }
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
    
    @MainActor
    func getUserFriends(userID: Int) async {
        let friends = try? await gameNightService.getUserFriends(userID: userID)
        if let friends = friends {
            self.userFriends = friends
            self.filteredFriends = friends
        }
    }
    
    @MainActor
    func filterFriends(searchText: String) {
        filteredFriends = userFriends.filter { friend in
            friend.username.lowercased().starts(with: searchText.lowercased())
            
        }
        filteredFriends.sort { $0.username.lowercased() < $1.username.lowercased() }
    }
    
    func addFriend(friend: UserPublicModel) {
        selectedFriends.append(friend)
        print(selectedFriends)
    }
}
