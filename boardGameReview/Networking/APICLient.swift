//
//  APIClient.swift
//  BoardGameReview
//
//  Created by Robert Fusting on 12/6/25.
//

import Foundation

final class APIClient {
    
    static let shared = APIClient()
    private let session: URLSession
    
    private init() {
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 30
        config.timeoutIntervalForResource = 60
        config.waitsForConnectivity = true
        config.httpAdditionalHeaders = ["Content-Type": "application/json"]
        self.session = URLSession(configuration: config)
        }
    
    func authorizedRequest(_ request: inout URLRequest, accessToken: String?) throws {
            guard let token = accessToken, !token.isEmpty else {
                throw APIError.missingAccessToken
            }
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
    
    func getSession() -> URLSession {
        return session
    }
}


