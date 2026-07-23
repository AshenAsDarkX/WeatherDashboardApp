//
//  MapView.swift
//  WeatherDashboardTemplate
//
//  Created by girish lukka on 18/10/2025.
//

import SwiftUI
import MapKit
import SwiftData

struct MapView: View {
    @EnvironmentObject var vm: MainAppViewModel
    
    // Control the camera position with state
    @State private var cameraPosition: MapCameraPosition = .automatic
    @Environment(\.openURL) var openURL
    

    var body: some View {
        VStack(spacing: 0) {
            
            // MARK: - TOP HALF: Interactive map
            VStack(spacing: 0) {
                Map(position: $cameraPosition) {
                    
                    // Display markers for the top 5 POIs
                    ForEach(vm.pois.prefix(5)) { poi in
                        Annotation(poi.name, coordinate: CLLocationCoordinate2D(latitude: poi.latitude, longitude: poi.longitude)) {
                            Image(systemName: "mappin.circle.fill")
                                .resizable()
                                .frame(width: 30, height: 30)
                                .foregroundColor(.red)
                                .background(Color.white)
                                .clipShape(Circle())
                                .shadow(radius: 2)
                                .onTapGesture {
                                    // Zoom in to 500m on tap
                                    let newRegion = MKCoordinateRegion(
                                        center: CLLocationCoordinate2D(latitude: poi.latitude, longitude: poi.longitude),
                                        latitudinalMeters: 500,
                                        longitudinalMeters: 500)
                                    withAnimation {
                                        self.cameraPosition = .region(newRegion)
                                    }
                                }
                                .contextMenu {
                                    Button {
                                        let searchString = "https://www.google.com/search?q=\(poi.name)"
                                        if let encoded = searchString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
                                           let url = URL(string: encoded) {
                                            openURL(url)
                                        }
                                    } label: {
                                        Label("Search on Google", systemImage: "magnifyingglass")
                                    }
                                }
                        }
                    }
                }
                // Automatically update map if the user searches for a new city
                .onChange(of: vm.mapRegion) { oldValue, newRegion in
                    withAnimation {
                        cameraPosition = .region(newRegion)
                    }
                }
                .ignoresSafeArea(edges: .top)
            }
                
            // MARK: - BOTTOM HALF: List of Attractions
            ZStack(alignment: .top) {
                LinearGradient(gradient: Gradient(colors: [Color.blue.opacity(0.6), Color.purple.opacity(0.6)]),
                               startPoint: .topLeading,
                               endPoint: .bottomTrailing)
                .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    Text("Top 5 Tourist Attractions in \(vm.activePlaceName.isEmpty ? "London" : vm.activePlaceName)")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(Color.blue.opacity(0.6))
                    
                    // The List
                    ScrollView {
                        VStack(spacing: 15) {
                            // Show only the top 5 (or fewer if not enough data)
                            ForEach(vm.pois.prefix(5)) { poi in
                                HStack(spacing: 15) {
                                    Image(systemName: "mappin.circle.fill")
                                        .resizable()
                                        .frame(width: 25, height: 25)
                                        .foregroundColor(.orange)
                                        .background(Color.white)
                                        .clipShape(Circle())
                           
                                    Text(poi.name)
                                        .font(.headline)
                                        .foregroundColor(.white)
                                    
                                    Spacer()
                                }
                                .padding(.horizontal)
                                .padding(.top, 5)
                                .contentShape(Rectangle())
                                .onTapGesture {
                                    // Same Zoom logic as the map pin
                                    let newRegion = MKCoordinateRegion(
                                        center: CLLocationCoordinate2D(latitude: poi.latitude, longitude: poi.longitude),
                                        span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
                                        )
                                    
                                    withAnimation {
                                        cameraPosition = .region(newRegion)
                                    }
                                }
                            }
                        }
                        .padding(.top, 20)
                        
                    }
                    .scrollContentBackground(.hidden)
                }
            }
        }
        .ignoresSafeArea()
    }
}

// Helper to make regions comparable
extension MKCoordinateRegion: @retroactive Equatable {
    public static func == (lhs: MKCoordinateRegion, rhs: MKCoordinateRegion) -> Bool {
        return lhs.center.latitude == rhs.center.latitude &&
               lhs.center.longitude == rhs.center.longitude &&
               lhs.span.latitudeDelta == rhs.span.latitudeDelta &&
               lhs.span.longitudeDelta == rhs.span.longitudeDelta
    }
}

#Preview {

    let container = ModelContainer.preview
    let vm = MainAppViewModel(context: container.mainContext)
    
    vm.activePlaceName = "London"
    vm.mapRegion = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 51.5074, longitude: -0.1278),
        span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
    )
    
    // Add dummy POIs to match screenshot style
    vm.pois = [
        AnnotationModel(name: "Roman Wall", latitude: 51.5, longitude: -0.1),
        AnnotationModel(name: "The View From The Shard", latitude: 51.5, longitude: -0.1),
        AnnotationModel(name: "Tower Torture", latitude: 51.5, longitude: -0.1),
        AnnotationModel(name: "Tower Bridge", latitude: 51.5, longitude: -0.1),
        AnnotationModel(name: "The Queen's Walk", latitude: 51.5, longitude: -0.1)
    ]
    
    return MapView()
        .environmentObject(vm)
        .modelContainer(container)
}
