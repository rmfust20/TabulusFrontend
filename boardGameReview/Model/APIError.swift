import Foundation

enum APIError: Error, LocalizedError {
    case invalidURL
    case noData
    case decodingFailed
    case serverError(statusCode: Int, message: String)
    case networkError(Error)
    case unknown
    case invalidResponse
    case invalidImageData
    case httpStatus(Int)
    case missingAccessToken


    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "The URL is invalid."
        case .noData:
            return "No data was returned from the server."
        case .decodingFailed:
            return "Failed to decode the server response."
        case .serverError(_, let message):
            return message
        case .networkError(let error):
            return error.localizedDescription
        case .unknown:
            return "An unknown error occurred."
        case .invalidResponse:
            return "The server response was invalid."
        case .invalidImageData:
            return "The image data is invalid."
        case .httpStatus(let statusCode):
            return "HTTP Error with status code: \(statusCode)."
        case .missingAccessToken:
            return "Access token is missing."
        }
    }
}

