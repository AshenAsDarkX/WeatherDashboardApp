//
//  WeatherDetailRow.swift
//  WeatherDashboardTemplate
//
//  Created by Ashen on 2025-12-26.
//

import Foundation
import SwiftUI

struct DetailWidget: View {
    let icon: String
    let title: String
    let value: String
    
    var body: some View {
        VStack(spacing: 5) {
            Image(systemName: icon)
                .font(.title)
                .foregroundColor(.white)
            Text(title)
                .font(.subheadline)
                .foregroundColor(.white.opacity(0.7))
            Text(value)
                .font(.headline)
                .foregroundColor(.white)
        }
        .frame(maxWidth: .infinity)
    }
}
