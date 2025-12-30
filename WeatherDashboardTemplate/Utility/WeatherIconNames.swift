//
//  WeatherIconNames.swift
//  WeatherDashboardTemplate
//
//  Created by Ashen on 2025-12-26.
//

import Foundation

import SwiftUI

enum WeatherIcon {
    case thunderstorm
    case drizzle
    case rain
    case snow
    case atmosphere // fog, mist, etc.
    case clear
    case clouds
    case unknown

    // Initialize the enum from the OpenWeather 'id' code
    init(code: Int) {
        switch code {
        case 200...232: self = .thunderstorm
        case 300...321: self = .drizzle
        case 500...531: self = .rain
        case 600...622: self = .snow
        case 701...781: self = .atmosphere
        case 800:       self = .clear
        case 801...804: self = .clouds
        default:        self = .unknown
        }
    }

    // Computed property to get the SF Symbol name
    var systemImage: String {
        switch self {
        case .thunderstorm: return "cloud.bolt.rain.fill"
        case .drizzle:      return "cloud.drizzle.fill"
        case .rain:         return "cloud.rain.fill"
        case .snow:         return "cloud.snow.fill"
        case .atmosphere:   return "cloud.fog.fill"
        case .clear:        return "sun.max.fill"
        case .clouds:       return "cloud.fill"
        case .unknown:      return "questionmark.circle"
        }
    }
}
