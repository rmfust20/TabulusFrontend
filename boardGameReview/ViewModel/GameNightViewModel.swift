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
    @Published var gameNightDurations: [Int:Int] = [:]
    @Published var description: String = ""
    @Published var selectedWinners : [Int:[Int]] = [:]
    
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
    
    func resolveToggle(_ friendID: Int, winnerCaller: Int?) {
        //if its a winnerCaller -> we add to selectedWinners and selectedFriends
        // we also remove from winnerCaller at that key
        
        // if its not a winnerCaller we remove from selectedFreidns and add to selected friends
        
        if let winnerCaller = winnerCaller {
            // one mode
            if selectedWinners[winnerCaller]?.contains(friendID) ?? false {
                selectedWinners[winnerCaller]?.removeAll { $0 == friendID }
            }
            
            else {
                if let friendToAdd = userFriends.first(where: { $0.id == friendID }) {
                    selectedWinners[winnerCaller, default: []].append(friendToAdd.id)
                    if !selectedFriends.contains(where: { $0.id == friendID }) {
                        selectedFriends.append(friendToAdd)
                    }
                    
                }
                
            }
        }
        
        else {
            if selectedFriends.contains(where: {$0.id == friendID}) {
                selectedFriends.removeAll { $0.id == friendID }
            }
            
            else {
                if let friendToAdd = userFriends.first(where: { $0.id == friendID }) {
                    selectedFriends.append(friendToAdd)
                }
            }
        }
    }
    
    func handleIsSelected(friendID: Int, winnerCaller: Int?) -> Bool {
        if let winnerCaller = winnerCaller {
            return selectedWinners[winnerCaller]?.contains(friendID) ?? false
        }
        return selectedFriends.contains(where: { $0.id == friendID })
    }
    
    func getGameNightSessions() -> [GameNightSessionUploadModel] {
        var sessions: [GameNightSessionUploadModel] = []
        for game in selectedGames {
            let duration = gameNightDurations[game.id] ?? 0
            let winners = selectedWinners[game.id] ?? []
            let session = GameNightSessionUploadModel(board_game_id: game.id, duration_minutes: duration, winner_user_ids: winners)
            sessions.append(session)
        }
        return sessions
        }
    
    func uploadGameNight(auth: Auth, images: [UploadImagesResponse.UploadedFile]) async {
        
        let blobNames = images.compactMap { $0.blob_name }
        
        let gameNightUploadModel = GameNightUploadModel(
            host_user_id: auth.userID ?? 0,
            description: self.description,
            // come back for images in a second
            images: blobNames,
            sessions: getGameNightSessions(),
            users: selectedFriends.compactMap {$0.id})
        
        try? await gameNightService.postGameNight(gameNight: gameNightUploadModel, accessToken: auth.accessToken ?? "")
            
    }
}
