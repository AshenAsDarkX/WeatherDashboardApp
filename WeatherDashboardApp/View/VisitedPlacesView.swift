//
//  VisitedPLacesView.swift
//  WeatherDashboardTemplate
//
//  Created by ashen himeshana.
//

import SwiftUI
import SwiftData


struct VisitedPlacesView: View {
    @EnvironmentObject var vm: MainAppViewModel
    @Environment(\.modelContext) private var context // Not used in body, but kept for completeness
    
    @Environment(\.openURL) var openURL
    
    // MARK:  add local variables for this view
    @Query(sort: \Place.lastUsedAt, order: .reverse) private var visitedPlaces: [Place]
    
    var body: some View {
        ZStack {
            LinearGradient(gradient: Gradient(colors: [Color.blue.opacity(0.6), Color.purple.opacity(0.6)]),
                           startPoint: .topLeading,
                           endPoint: .bottomTrailing)
            .ignoresSafeArea()
            
            VStack(alignment: .leading, spacing: 0){
                Text("Visited Places")
                    .font(.system(size: 30, weight: .bold))
                    .padding(.top, 75)
                    .padding(.horizontal)
                if vm.visited.isEmpty {
                    ContentUnavailableView("No places saved", systemImage: "mappin.slash")
                }
                else{
                    List{
                        ForEach(vm.visited){
                            place in VStack(alignment: .leading){
                                Text(place.name)
                                    .font(.headline)
                                Text("Lat: \(place.latitude), Lon: \(place.longitude)")
                                    .font(.caption)
                            }
                            .contentShape(Rectangle())
                            .onTapGesture {
                                // Load the place locally and switch tab
                                Task {
                                    await vm.loadLocation(fromPlace: place)
                                }
                                vm.selectedTab = 0 // Switch to Home Tab
                            }
                            .onLongPressGesture{
                                // Google Search Feature
                                let searchString = "https://www.google.com/search?q=\(place.name)"
                                if let encodedSearchString = searchString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
                                    ,let url = URL(string: encodedSearchString) {
                                        openURL(url)
                                    }
                            }
                        }
                        // Swipe to delete triggers ViewModel logic
                        .onDelete(perform: vm.delete)
                        .listRowBackground(RoundedRectangle(cornerRadius: 8).fill(Color.white.opacity(0.5)).padding(.vertical, 6))
                        .listRowSeparator(.hidden)
                    }
                    .scrollContentBackground(.hidden)
                    .listStyle(.plain)
                    .padding(10)
                    .cornerRadius(20)
                }
            }
        }
    }
}



#Preview {
    // Create an in-memory database for previewing
    let container = ModelContainer.preview
    
    let vm = MainAppViewModel(context: container.mainContext)
    
    return VisitedPlacesView()
        .environmentObject(vm)
        .modelContainer(container)
}
