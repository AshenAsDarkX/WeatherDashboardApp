//
//  WeatherService.swift
//  WeatherDashboardTemplate
//
//  Created by ashen himeshana.
//

import Foundation
import CoreLocation

@MainActor
final class WeatherService {
    private var apiKey: String {
        if let envKey = ProcessInfo.processInfo.environment["OPENWEATHER_API_KEY"], !envKey.isEmpty {
            return envKey
        }
        if let url = Bundle.main.url(forResource: "Secrets", withExtension: "plist"),
           let data = try? Data(contentsOf: url),
           let plist = try? PropertyListSerialization.propertyList(from: data, options: [], format: nil) as? [String: Any],
           let key = plist["OpenWeatherAPIKey"] as? String, !key.isEmpty {
            return key
        }
        return "YOUR_OPENWEATHER_API_KEY"
    }

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
