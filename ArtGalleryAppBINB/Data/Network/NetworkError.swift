//
//  NetworkError.swift
//  ArtGallery
//
//  Network error definitions
//

import Foundation

enum NetworkError: LocalizedError {
    case invalidURL
    case noData
    case decodingError
    case serverError(Int)
    case noInternetConnection
    case timeout
    case unknown(Error)
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid URL"
        case .noData:
            return "No data received from server"
        case .decodingError:
            return "Failed to process server response"
        case .serverError(let code):
            return "Server error (\(code))"
        case .noInternetConnection:
            return "No internet connection. Please check your connection."
        case .timeout:
            return "Request timed out. Please try again."
        case .unknown(let error):
            return error.localizedDescription
        }
    }
    
    var recoverySuggestion: String? {
        switch self {
        case .noInternetConnection:
            return "Check your internet connection and try again."
        case .timeout:
            return "The request took too long. Please try again."
        case .serverError:
            return "Please try again later."
        default:
            return "Please try again."
        }
    }
}
