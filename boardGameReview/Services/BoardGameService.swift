import Foundation
import UIKit

struct BoardGameService {
    let client: APIClient
    let baseURL: String

    init(client: APIClient = APIClient.shared) {
        self.client = client
        self.baseURL = "http://127.0.0.1:8000"
    }

    func fetchBoardGameFeedForUser(_ userID: String, _ url: inout String, _ lastSeenID: Int) async throws -> [BoardGameModel] {
        if lastSeenID > 0 {
            url += "?lastSeenID=\(lastSeenID)"
        }
        
        guard let url = URL(string: url) else {
            throw APIError.invalidURL
        }


        let (data, response) = try await client.getSession().data(from: url)
        guard let http = response as? HTTPURLResponse, (200...299).contains(http.statusCode) else {
            throw APIError.serverError(statusCode: (response as? HTTPURLResponse)?.statusCode ?? 0,
                                       message: "Server error")
        }

        return try JSONDecoder().decode([BoardGameModel].self, from: data)
    }
    
    func rehydrate(userID: Int, boardGameIds: [Int]) async throws -> [BoardGameModel] {
            guard !boardGameIds.isEmpty else { return [] }

            var components = URLComponents(string: baseURL)
            components?.path = "/boardGames/user/\(userID)/rehydrate"
            components?.queryItems = boardGameIds.map { URLQueryItem(name: "board_game_ids", value: String($0)) }
        

            guard let url = components?.url else { throw APIError.invalidURL }

        let (data, response) = try await client.getSession().data(from: url)

            guard let http = response as? HTTPURLResponse else { throw APIError.invalidResponse }
            guard (200...299).contains(http.statusCode) else { throw APIError.httpStatus(http.statusCode) }

            return try JSONDecoder().decode([BoardGameModel].self, from: data)
        }
    
    func fetchBoardGame(_ url : String) async throws -> BoardGameModel {
        guard let url = URL(string: url) else {
            throw APIError.invalidURL
        }

        let (data, response) = try await client.getSession().data(from:url)
        guard let http = response as? HTTPURLResponse, (200...299).contains(http.statusCode) else {
            throw APIError.serverError(statusCode: (response as? HTTPURLResponse)?.statusCode ?? 0,
                                       message: "Server error")
        }
        
        return try JSONDecoder().decode(BoardGameModel.self, from: data)

    }
    
    func fetchBoardGameImage(_ urlString: String) async throws -> UIImage {
        guard let url = URL(string: urlString) else {
            throw APIError.invalidURL
        }

        let (data, response) = try await client.getSession().data(from: url)

        guard let http = response as? HTTPURLResponse else {
            throw APIError.invalidResponse
        }

        guard (200...299).contains(http.statusCode) else {
            throw APIError.httpStatus(http.statusCode)
        }

        guard let image = UIImage(data: data) else {
            throw APIError.invalidImageData
        }

        return image
    }
    
    func fetchBoardGameDesigners(_ boardGameID: Int) async throws -> [String] {
        var components = URLComponents(string: baseURL)
        components?.path = "/boardGames/designers/\(boardGameID)"
        
        guard let url = components?.url else { throw APIError.invalidURL }
        
        let (data, response) = try await client.getSession().data(from: url)
        
        

        guard let http = response as? HTTPURLResponse else { throw APIError.invalidResponse }
        guard (200...299).contains(http.statusCode) else { throw APIError.httpStatus(http.statusCode) }
        

        let designers = try JSONDecoder().decode([BoardGameDesingnerModel].self, from: data)
        return designers.map { $0.name }.sorted()
        
    }
}

