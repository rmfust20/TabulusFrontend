//
//  UserService.swift
//  boardGameReview
//
//  Created by Robert Fusting on 1/18/26.
//

import Foundation

struct UserService {
    let client: APIClient
    let baseURL: String
    
    init(client: APIClient = APIClient.shared) {
        self.client = client
        //self.baseURL = "https://tabulusapp.bravegrass-0afbc7b6.westus2.azurecontainerapps.io"
        self.baseURL = "https://tabulusapp.bravegrass-0afbc7b6.westus2.azurecontainerapps.io"
    }
    
    func registerUser(user: UserModel) async throws -> RegisterResponse {
        var components = URLComponents(string: baseURL)
        components?.path = "/users/register"
        guard let url = components?.url else { throw APIError.invalidURL }
        
        var request = URLRequest(url: url)
        
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let encoder = JSONEncoder()
        let data = try encoder.encode(user)
        request.httpBody = data
        
        let (responseData, response) = try await client.getSession().data(for: request)
        
        guard let http = response as? HTTPURLResponse else { throw APIError.invalidResponse }
        guard (200...299).contains(http.statusCode) else { throw APIError.httpStatus(http.statusCode) }
        
        return try JSONDecoder().decode(RegisterResponse.self, from: responseData)
    }
    
    func login(username: String, password: String) async throws -> AuthResponse {
        var components = URLComponents(string: baseURL)
        components?.path = "/users/login"
        guard let url = components?.url else { throw APIError.invalidURL }
        
        var request = URLRequest(url: url)
        
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let encoder = JSONEncoder()
        let loginData = ["username": username, "password": password]
        let data = try encoder.encode(loginData)
        request.httpBody = data
        
        let (responseData, response) = try await client.getSession().data(for: request)
        
        guard let http = response as? HTTPURLResponse else { throw APIError.invalidResponse }
        guard (200...299).contains(http.statusCode) else { throw APIError.httpStatus(http.statusCode) }
        
        return try JSONDecoder().decode(AuthResponse.self, from: responseData)
    }
    
    func updateUser(updatedUser: UserProfileModel, accessToken: String) async throws -> UserProfileModel {
        print("starting updated")
        var components = URLComponents(string: baseURL)
        components?.path = "/users/updateUser"
        guard let url = components?.url else { throw APIError.invalidURL }
        
        var request = URLRequest(url: url)
        try client.authorizedRequest(&request, accessToken: accessToken)
        
        request.httpMethod = "PATCH"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let encoder = JSONEncoder()
        let data = try encoder.encode(updatedUser)
        request.httpBody = data
        
        print("this farrrr")
        let (responseData, response) = try await client.getSession().data(for: request)
        print("her?")
        
        guard let http = response as? HTTPURLResponse else { throw APIError.invalidResponse }
        guard (200...299).contains(http.statusCode) else { throw APIError.httpStatus(http.statusCode) }
        
        let updated = try JSONDecoder().decode(UserProfileModel.self, from: responseData)
        print(updated)
        return updated
    }
    
    func getUser(userID: Int) async throws -> UserProfileModel {
        var components = URLComponents(string: baseURL)
        components?.path = "/users/userProfile/\(userID)"
        guard let url = components?.url else { throw APIError.invalidURL }
        
        var request = URLRequest(url: url)
        //try client.authorizedRequest(&request, accessToken: accessToken)
        
        // ✅ Use the request, not the raw url
        let (data, response) = try await client.getSession().data(for: request)
        
        print("did i get here?")
        
        guard let http = response as? HTTPURLResponse else { throw APIError.invalidResponse }
        guard (200...299).contains(http.statusCode) else { throw APIError.httpStatus(http.statusCode) }
        
        let user = try JSONDecoder().decode(UserProfileModel.self, from: data)
        return user
    }
    
    func getUserFriendsPending(userID: Int, accessToken: String) async throws -> [UserPublicModel] {
        var components = URLComponents(string: baseURL)
        components?.path = "/users/pendingFriends/\(userID)"
        guard let url = components?.url else { throw APIError.invalidURL }
        
        var request = URLRequest(url: url)
        //try client.authorizedRequest(&request, accessToken: accessToken)
        
        // ✅ Use the request, not the raw url
        let (data, response) = try await client.getSession().data(for: request)
        
        print("did i get here?")
        
        guard let http = response as? HTTPURLResponse else { throw APIError.invalidResponse }
        guard (200...299).contains(http.statusCode) else { throw APIError.httpStatus(http.statusCode) }
        
        let users = try JSONDecoder().decode([UserPublicModel].self, from: data)
        return users
    }
    
    func sendFriendRequest(userID: Int, friendID: Int, accessToken: String) async throws {
        var components = URLComponents(string: baseURL)
        components?.path = "/users/sendFriendRequest/\(userID)/\(friendID)"
        guard let url = components?.url else { throw APIError.invalidURL }
        
        var request = URLRequest(url: url)
        try client.authorizedRequest(&request, accessToken: accessToken)
        request.httpMethod = "POST"
        
        let (_, response) = try await client.getSession().data(for: request)
        
        guard let http = response as? HTTPURLResponse else { throw APIError.invalidResponse }
        guard (200...299).contains(http.statusCode) else { throw APIError.httpStatus(http.statusCode) }
    }

    func removeFriend(userID: Int, friendID: Int, accessToken: String) async throws {
        var components = URLComponents(string: baseURL)
        components?.path = "/users/removeFriend/\(userID)/\(friendID)"
        guard let url = components?.url else { throw APIError.invalidURL }

        var request = URLRequest(url: url)
        try client.authorizedRequest(&request, accessToken: accessToken)
        request.httpMethod = "DELETE"

        let (_, response) = try await client.getSession().data(for: request)

        guard let http = response as? HTTPURLResponse else { throw APIError.invalidResponse }
        guard (200...299).contains(http.statusCode) else { throw APIError.httpStatus(http.statusCode) }
    }
    
    func acceptFriend(userID: Int, friendID: Int, accessToken: String) async throws {
        var components = URLComponents(string: baseURL)
        components?.path = "/users/acceptFriend/\(userID)/\(friendID)"
        guard let url = components?.url else { throw APIError.invalidURL }

        var request = URLRequest(url: url)
        try client.authorizedRequest(&request, accessToken: accessToken)
        request.httpMethod = "POST"

        let (_, response) = try await client.getSession().data(for: request)

        guard let http = response as? HTTPURLResponse else { throw APIError.invalidResponse }
        guard (200...299).contains(http.statusCode) else { throw APIError.httpStatus(http.statusCode) }
    }
    
    func rejectFriend(userID: Int, friendID: Int, accessToken: String) async throws {
        var components = URLComponents(string: baseURL)
        components?.path = "/users/rejectFriend/\(userID)/\(friendID)"
        guard let url = components?.url else { throw APIError.invalidURL }

        var request = URLRequest(url: url)
        try client.authorizedRequest(&request, accessToken: accessToken)
        request.httpMethod = "POST"

        let (_, response) = try await client.getSession().data(for: request)

        guard let http = response as? HTTPURLResponse else { throw APIError.invalidResponse }
        guard (200...299).contains(http.statusCode) else { throw APIError.httpStatus(http.statusCode) }
    }
    
    func getSentFriendRequests(userID: Int, accessToken: String) async throws -> [UserPublicModel] {
        var components = URLComponents(string: baseURL)
        components?.path = "/users/sentFriendRequests/\(userID)"
        guard let url = components?.url else { throw APIError.invalidURL }

        var request = URLRequest(url: url)
        try client.authorizedRequest(&request, accessToken: accessToken)

        let (data, response) = try await client.getSession().data(for: request)

        guard let http = response as? HTTPURLResponse else { throw APIError.invalidResponse }
        guard (200...299).contains(http.statusCode) else { throw APIError.httpStatus(http.statusCode) }

        return try JSONDecoder().decode([UserPublicModel].self, from: data)
    }

    func searchUsers(username: String) async throws -> [UserPublicModel] {
        var components = URLComponents(string: baseURL)
        components?.path = "/users/search"
        components?.queryItems = [URLQueryItem(name: "username", value: username)]
        guard let url = components?.url else { throw APIError.invalidURL }

        var request = URLRequest(url: url)

        let (data, response) = try await client.getSession().data(for: request)

        guard let http = response as? HTTPURLResponse else { throw APIError.invalidResponse }
        guard (200...299).contains(http.statusCode) else { throw APIError.httpStatus(http.statusCode) }

        return try JSONDecoder().decode([UserPublicModel].self, from: data)
    }

    func logout(refreshToken: String) async throws {
        var components = URLComponents(string: baseURL)
        components?.path = "/users/logout"
        components?.queryItems = [URLQueryItem(name: "refresh_token", value: refreshToken)]
        guard let url = components?.url else { throw APIError.invalidURL }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"

        let (_, response) = try await client.getSession().data(for: request)

        guard let http = response as? HTTPURLResponse else { throw APIError.invalidResponse }
        guard (200...299).contains(http.statusCode) else { throw APIError.httpStatus(http.statusCode) }
    }

    func deleteAccount(accessToken: String) async throws {
        var components = URLComponents(string: baseURL)
        components?.path = "/users/deleteAccount"
        guard let url = components?.url else { throw APIError.invalidURL }

        var request = URLRequest(url: url)
        try client.authorizedRequest(&request, accessToken: accessToken)

        request.httpMethod = "DELETE"

        let (_, response) = try await client.getSession().data(for: request)

        guard let http = response as? HTTPURLResponse else { throw APIError.invalidResponse }
        guard (200...299).contains(http.statusCode) else { throw APIError.httpStatus(http.statusCode) }
    }

}
