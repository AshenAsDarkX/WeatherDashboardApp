//
//  CurrentWeatherView.swift
//  WeatherDashboardTemplate
//
//  Created by girish lukka on 18/10/2025.
//

import SwiftUI
import SwiftData


struct CurrentWeatherView: View {
    @EnvironmentObject var vm: MainAppViewModel
    
    var body: some View {
        // Safe unwrap of the weather data
        let currentTemp = vm.currentWeather?.current.temp ?? 0
        let currentDesc = vm.currentWeather?.current.weather.first?.description ?? "unknown"
        let advice = WeatherAdviceCategory.from(temp: currentTemp, description: currentDesc) // Calculate the "Smart Advice" based on temp
        
        ZStack {
            LinearGradient(gradient: Gradient(colors: [Color.blue.opacity(0.6), Color.purple.opacity(0.6)]),
                           startPoint: .topLeading,
                           endPoint: .bottomTrailing)
            .ignoresSafeArea()
            
            
            ScrollView{
                if let weather = vm.currentWeather {
                    HStack{
                        Text(vm.activePlaceName.isEmpty ? "London" : vm.activePlaceName)
                            .font(.system(size: 30, weight: .bold))
                            .foregroundColor(.black)
                        Spacer()
                        Text(DateFormatterUtils.formattedDateWithDay(from: TimeInterval(weather.current.dt)))
                            .font(.subheadline)
                            .foregroundColor(.blue)
                    }
                    .padding(.top, 75)
                    .padding(.horizontal, 10)
                    VStack(alignment: .leading, spacing: 30){
                        HStack{
                            Text("\(Int(weather.current.temp))°C")
                                .font(.system(size: 60, weight: .bold))
                            Spacer()
                            Image(systemName: WeatherIcon(code: weather.current.weather.first?.id ?? 800).systemImage)
                                .font(.system(size: 60, weight: .bold))
                        }
                        .padding(20)
                        VStack(alignment: .leading, spacing: 10){
                            Text(weather.current.weather.first?.description.capitalized ?? "Unknown")
                                .font(.title3.bold())
                            if let daily = weather.daily.first {
                                HStack(spacing: 20) {
                                    // Using Daily struct properties
                                    HStack{
                                        Image(systemName: "arrow.up")
                                        Text("\(Int(daily.temp.max))°C")
                                    }
                                    HStack{
                                        Image(systemName: "arrow.down")
                                        Text("\(Int(daily.temp.min))°C")
                                    }
                                    
                                    
                                }
                                .foregroundColor(.white.opacity(0.9))
                            }
                        }
                        .padding(.horizontal)
                        Divider()
                        Text("Details")
                            .padding(.horizontal)
                            .font(.title3.bold())
                            .foregroundColor(.black.opacity(0.5))
                        HStack{
                            // Detail Widgets (Pressure, Sunrise, Sunset)
                            DetailWidget(icon: "gauge", title: "Pressure", value: "\(weather.current.pressure)hPa")
                            DetailWidget(icon: "sunrise.fill", title: "Sunrise", value: DateFormatterUtils.formattedDate12Hour(from: TimeInterval(weather.current.sunrise)))
                            DetailWidget(icon: "sunset.fill", title: "Sunset", value: DateFormatterUtils.formattedDate12Hour(from: TimeInterval(weather.current.sunset)))
                            
                        }
                        // Smart Advice Widget
                        HStack(){
                            Image(systemName: advice.icon)
                                .font(.system(size: 50))
                                .foregroundColor(advice.color)
                                .padding(10)
                            Spacer(minLength: 5)
                            Text(advice.adviceText)
                                .font(.system(size: 20).weight(.semibold))
                                .padding()
                        }
                        .background(Color(advice.color).opacity(0.1))
                        .cornerRadius(10)
                        .padding()
                        
                    }
                    .background(Color(.white).opacity(0.1))
                    .cornerRadius(10)
                    .shadow(color: Color.black.opacity(0.3), radius: 5, x: 4, y: 4)
                    .padding(10)
                    
                    
                }
                else {
                    // Loading State
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
    CurrentWeatherView()
        .environmentObject(vm)
}

