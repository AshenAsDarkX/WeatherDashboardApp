//
//  ForecastView.swift
//  WeatherDashboardTemplate
//
//  Created by girish lukka on 18/10/2025.
//

import SwiftUI
import Charts
import SwiftData

// Enum to color-code the chart bars based on temperature
enum TempCategory: String, CaseIterable {
    case freezing, cold, mild, warm, hot, boiling    // Example category

    /// Choose a color to represent this category.
    var color: Color {
        switch self {
        case .freezing: return .cyan
        case .cold: return .blue
        case .mild: return .yellow
        case .warm: return .orange
        case .hot: return .red
        case .boiling: return .brown
            // TODO: add more cases (e.g., .cool, .warm, .hot) with colors as needed
        }
    }

    /// Convert a Celsius temperature into a category.
    static func from(tempC: Double) -> TempCategory {
        if tempC <= 0 {
            return .freezing
        }
        if tempC <= 10 {
            return .cold
        }
        if tempC <= 20 {
            return .mild
        }
        if tempC <= 30 {
            return .warm
        }
        if tempC <= 40 {
            return .hot
        }
        // TODO: add more logic for other ranges (cool, warm, hot)
        return .boiling
    }
}

// Simple struct for Chart Data
private struct TempData: Identifiable {
    let id = UUID()
    let time: Date
    let type: String
    let value: Double
    let category: TempCategory
}

struct ForecastView: View {
    @EnvironmentObject var vm: MainAppViewModel

    // Transforms API data into format needed for Swift Charts
    private var chartData: [TempData] {
        
        if let weather = vm.currentWeather {
            return weather.daily.flatMap { day -> [TempData] in
                let date = Date(timeIntervalSince1970: TimeInterval(day.dt))
                
                return [
                    TempData(
                        time: date,
                        type: "High",
                        value: day.temp.max,
                        category: TempCategory.from(tempC: day.temp.max)
                    ),
                    TempData(
                        time: date,
                        type: "Low",
                        value: day.temp.min,
                        category: TempCategory.from(tempC: day.temp.min)
                    )
                ]
                
            }
        }
        else{
            return []
        }
    }

    var body: some View {
        ZStack {
            LinearGradient(gradient: Gradient(colors: [Color.blue.opacity(0.6), Color.purple.opacity(0.6)]),
                           startPoint: .topLeading,
                           endPoint: .bottomTrailing)
            .ignoresSafeArea()
            
            ScrollView{
                VStack(alignment: .leading){
                    Text("8-Day Forecast -\(vm.activePlaceName.isEmpty ? "Error Loading" : vm.activePlaceName)")
                        .font(.system(size: 30, weight: .bold))
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.top, 75)
                .padding(.horizontal, 15)
                .padding(.bottom, 0)
                
                if let weather = vm.currentWeather{
                    // MARK: - Bar Chart
                    VStack(alignment: .leading){
                        Text("Daily highs and lows (in °C)")
                            .font(.title3.bold())
                        
                        Chart {
                            ForEach(chartData) { dataPoint in
                                BarMark(
                                    x: .value("Day", dataPoint.time, unit: .day),
                                    y: .value("Temp", dataPoint.value)
                                )
                                .foregroundStyle(dataPoint.category.color)
                                .position(by: .value("Type", dataPoint.type))
                                .annotation(position: .top) {
                                    Text("\(Int(dataPoint.value))°")
                                        .font(.caption.bold())
                                        .foregroundColor(.white)
                                }
                                .cornerRadius(5)
                            }
                        }
                        .chartXAxis {AxisMarks(values: .stride(by: .day)) { value in
                            AxisValueLabel(format: .dateTime.weekday(), centered: true) //Shows "Mon","Tue"
                                .foregroundStyle(Color.white)
                        }
                        }
                        .chartYAxis {
                            AxisMarks {
                                AxisValueLabel()
                                    .foregroundStyle(Color.white)
                            }
                        }
                        .frame(height: 300) // Give the chart some space
                        
                    }
                    .padding()
                    .background(Color.black.opacity(0.3))
                    .cornerRadius(15)
                    .padding()
                                    
                    Spacer()
                    Divider()
                    
                    // MARK: - List Summary
                    VStack(alignment: .leading, spacing: 1){
                        Text("Detailed daily summary")
                            .font(.title3.bold())
                            .frame(maxWidth: .infinity, alignment: .init(horizontal: .leading, vertical: .top))
                            .padding()
                        LazyVStack(spacing: 2) {
                            ForEach(weather.daily, id: \.dt) { day in
                                VStack(alignment: .leading) {
                                    
                                    // Day Name (Using your new Utility)
                                    Text(DateFormatterUtils.formattedDayName(from: day.dt))
                                        .font(.headline)
                                        .foregroundColor(.black)
                                        .frame( alignment: .leading)
                                    Spacer()
                                    
                                    // Description
                                    Text(day.summary.capitalized.isEmpty ? "Unknown" : day.summary.capitalized)
                                        .font(.subheadline.italic())
                                        .foregroundColor(.white.opacity(0.8))
                                    
                                    // Temps
                                    Text(" Low: \(Int(day.temp.max))°C | High: \(Int(day.temp.min))°C")
                                        .font(.caption2)
                                        .fontWeight(.semibold)
                                        .foregroundColor(.black)
                                }
                                .padding()
                                .frame(maxWidth: .infinity, alignment: .leading)
                                
                                Divider()
                                
                            }
                            
                        }
                        .padding(.bottom, 20)
//                        .padding()
                        
                    }
                    .background(Color.black.opacity(0.2))
                    .cornerRadius(15)
                    .padding()
                    
                }
                else{
                    VStack {
                        Spacer()
                        ProgressView()
                            .tint(.white)
                            .scaleEffect(1.5)
                        Text("Loading Weather...")
                            .foregroundColor(.white)
                            .padding()
                        Spacer()
                    }
                    .frame(minHeight: 400)
                }
                
                
            }
            
        }
    }
}

#Preview {
    let vm = MainAppViewModel(context: ModelContext(ModelContainer.preview))
    ForecastView()
        .environmentObject(vm)
}
