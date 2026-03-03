//
//  GameNightService.swift
//  boardGameReview
//
//  Created by Robert Fusting on 2/26/26.
//

import Foundation

struct GameNightService {
    let client: APIClient
    let baseURL: String

    init(client: APIClient = APIClient.shared) {
        self.client = client
        //self.baseURL = "https://tabulusapp.bravegrass-0afbc7b6.westus2.azurecontainerapps.io"
        self.baseURL = "http://127.0.0.1:8000"
    }
    
    func getUserFriends(userID: Int) async throws -> [UserPublicModel] {
        var components = URLComponents(string: baseURL)
        components?.path = "/users/friends/\(userID)"
        guard let url = components?.url else { throw APIError.invalidURL }
        
        var request = URLRequest(url: url)
        //try client.authorizedRequest(&request, accessToken: accessToken)
        
        let (data, response) = try await client.getSession().data(from: url)
        
        

        guard let http = response as? HTTPURLResponse else { throw APIError.invalidResponse }
        guard (200...299).contains(http.statusCode) else { throw APIError.httpStatus(http.statusCode) }
        
        let friends = try JSONDecoder().decode([UserPublicModel].self, from: data)
    
        return friends
    }
}
