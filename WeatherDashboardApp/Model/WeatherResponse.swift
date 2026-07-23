//
//  WeatherResponse.swift
//  WeatherDashboardTemplate
//
//  Created by girish lukka on 18/10/2025.
//

import Foundation

// This file was generated from JSON Schema using quicktype, do not modify it directly.
// To parse the JSON, add this file to your project and do:
//
//   let weatherResponse = try? JSONDecoder().decode(WeatherResponse.self, from: jsonData)

// MARK:  You can use this file however you will not get any credit for it. You must create your own WeatherResponse that is specific for your app and that it is efficient

import Foundation

// MARK: - WeatherResponse
struct WeatherResponse: Codable {
    let current: Current
    let daily: [Daily]
}

// MARK: - Current
struct Current: Codable {
    let dt, sunrise, sunset,pressure: Int
    let temp: Double
    let weather: [Weather]

    enum CodingKeys: String, CodingKey {
        case dt, sunrise, sunset, temp, pressure, weather
    }
}

// MARK: - Weather
struct Weather: Codable {
    let id: Int
    let main, description, icon: String
}

// MARK: - Daily
struct Daily: Codable {
    let dt: Int
    let summary: String
    let temp: Temp
    let weather: [Weather]

    enum CodingKeys: String, CodingKey {
        case dt
        case summary, temp
        case weather
    }
}

// MARK: - Temp
struct Temp: Codable {
    let min, max: Double
}

