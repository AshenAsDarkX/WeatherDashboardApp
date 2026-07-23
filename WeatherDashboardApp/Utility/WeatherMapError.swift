//  WeatherMapError.swift
//  WeatherDashboardTemplate
//
//  Created by ashen himeshana.
//
import Foundation

// Custom Error type so we can show user-friendly messages
enum WeatherMapError: Error, LocalizedError, Identifiable {
    case invalidURL(String)
    case networkError(Error)
    case decodingError(Error)
    case geocodingFailed(String)
    case invalidResponse(statusCode: Int)
    case missingData(message: String)
    case noInternetConnection // Added to handle offline states
    var id: String { localizedDescription }
    

    var errorDescription: String? {
        switch self {
        case .invalidURL(let urlString):
            return "Configuration Error: The URL is invalid or malformed: \(urlString)"
        case .networkError(let error):
            return "A network connection error occurred: \(error.localizedDescription)"
        case .decodingError(let error):
            return "Failed to parse data from the server: \(error.localizedDescription)"
        case .geocodingFailed(let location):
            return "Could not find coordinates for the location: \(location). Please try another name."
        case .invalidResponse(let code):
            return "The server returned an error code: \(code). Data is unavailable."
        case .missingData(let message):
            return "Missing or invalid data: \(message)"
            case .noInternetConnection:
            return "No internet connection available."
        }
    }
}
