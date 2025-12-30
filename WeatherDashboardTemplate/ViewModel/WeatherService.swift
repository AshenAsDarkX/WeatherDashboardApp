//
//  WeatherService.swift
//  WeatherDashboardTemplate
//
//  Created by girish lukka on 18/10/2025.
//

import Foundation
import CoreLocation

@MainActor
final class WeatherService {
    private let apiKey = "75e75a176012123295e1dbf8e6f4a80b"

    func fetchWeather(lat: Double, lon: Double) async throws -> WeatherResponse {
        // Constructs a URL for the OpenWeatherMap OneCall API using the provided coordinates and API key.
        let urlString = "https://api.openweathermap.org/data/3.0/onecall?lat=\(lat)&lon=\(lon)&exclude={part}&hourly&units=metric&appid=\(apiKey)"
        
        guard let url = URL(string: urlString) else {
            throw WeatherMapError.invalidURL(urlString)
        }
        do {
            let (data, response) = try await URLSession.shared.data(from: url)
            
            guard let httpResponse = response as? HTTPURLResponse,
                  (200...299).contains(httpResponse.statusCode) else {
                throw WeatherMapError.invalidResponse(statusCode: -1)
            }
            
           return try JSONDecoder().decode(WeatherResponse.self, from: data)
        } catch let error as DecodingError {
            throw WeatherMapError.decodingError(error)
        } catch let error as URLError {
            throw WeatherMapError.networkError(error)
        }
        // Performs an asynchronous network request using URLSession.
        // Validates the HTTP response status code.
        // Decodes the received JSON data into a `WeatherResponse` object, using a specific date decoding strategy.
        // Handles and throws specific `WeatherMapError` types for invalid URL, network failure, invalid response, and decoding errors.

        // DUMMY RETURN TO SATISFY COMPILER - you will have your own when the coding is done
//        preconditionFailure("Stubbed function not implemented. Requires a WeatherResponse return.")
    }
}
