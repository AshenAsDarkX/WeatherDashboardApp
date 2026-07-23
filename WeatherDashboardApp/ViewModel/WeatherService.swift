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
        // excluded 'minutely', 'hourly', and 'alerts' to reduce payload size.
        // Constructs a URL for the OpenWeatherMap OneCall API using the provided coordinates and API key.
        let urlString = "https://api.openweathermap.org/data/3.0/onecall?lat=\(lat)&lon=\(lon)&exclude=minutely,hourly,alerts&units=metric&appid=\(apiKey)"
        
        
        guard let url = URL(string: urlString) else {
            throw WeatherMapError.invalidURL(urlString)
        }
        do {
            let (data, response) = try await URLSession.shared.data(from: url)
            
            // Verify we got a 200 OK response from the server
            guard let httpResponse = response as? HTTPURLResponse,
                  (200...299).contains(httpResponse.statusCode) else {
                throw WeatherMapError.invalidResponse(statusCode: -1)
            }
            // Decode the JSON into our Swift model
           return try JSONDecoder().decode(WeatherResponse.self, from: data)
        } catch let error as DecodingError {
            throw WeatherMapError.decodingError(error)
        } catch let error as URLError {
            throw WeatherMapError.networkError(error)
        }
    }
}
