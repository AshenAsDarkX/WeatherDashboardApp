//
//  MainAppViewModel.swift
//  WeatherDashboardTemplate
//
//  Created by ashen himeshana.
//

import SwiftUI
import SwiftData
import MapKit

@MainActor
final class MainAppViewModel: ObservableObject {
    @Published var query = ""
    @Published var currentWeather: WeatherResponse?
    @Published var forecast: [Weather] = []
    @Published var pois: [AnnotationModel] = []
    @Published var mapRegion = MKCoordinateRegion()
    @Published var visited: [Place] = [] // The "Visited" list is managed by SwiftData but we keep a local copy here for the UI
    @Published var isLoading = false
    @Published var appError: WeatherMapError?
    @Published var activePlaceName: String = ""
    private let defaultPlaceName = "London"
    @Published var selectedTab: Int = 0
    @Published var showStorageAlert: Bool = false
    @Published var storageAlertMessage: String = ""

    // Services
    /// Create and use a WeatherService model (class) to manage fetching and decoding weather data
    private let weatherService = WeatherService()
    /// Create and use a LocationManager model (class) to manage address conversion and tourist places
    private let locationManager = LocationManager()
    /// Use a context to manage database operations
    private let context: ModelContext
    private let networkMonitor = NetworkMonitor() // Watches connection status

    init(context: ModelContext) {
        // Initialize the ModelContext and attempt to fetch previously visited places from SwiftData, sorted by most recent use.
        // If no visited places exist (first launch), load the default location.
        // Otherwise, load the most recently used place.
        self.context = context
        
        // On App Launch: Load visited places from DB (Most recently used first)
        if let results = try? context.fetch(
            FetchDescriptor<Place>(sortBy: [SortDescriptor(\Place.lastUsedAt, order: .reverse)])
        ) {
            self.visited = results
        }
        
        // If no history, load London. Else load the last visited place.
        if visited.isEmpty {
            Task {
                await loadDefaultLocation()
            }
        } else if let mostRecent = visited.first {
            // Otherwise, load most recently used place
            Task {
                await loadLocation(fromPlace: mostRecent, showAlert: false)
            }
        }
    }

    // Triggered when user hits "Submit" on the search bar
    func search() {
        let city = query.trimmingCharacters(in: .whitespacesAndNewlines)
        
        // Basic Validation
        guard !city.isEmpty else {
            appError = .missingData(message: "Please enter a valid location.")
            return
        }
        
        // Check internet before trying to fetch
        guard networkMonitor.isConnected else {
            appError = .noInternetConnection
            return
        }
        Task {
            do {
                try await loadLocation(byName: city)
                query = ""
            } catch {
                appError = .networkError(error)
            }
        }
    }
    
    // Loads the default city (London)
    func loadDefaultLocation() async {
        // Attempts to select and load the hardcoded default location name.
        // If an error occurs during selection, sets an app error.
        guard networkMonitor.isConnected else {
            appError = .noInternetConnection
            return
        }
        do {
            let data = try await weatherService.fetchWeather(lat: 51.5074, lon: -0.1278)
            self.currentWeather = data
            self.activePlaceName = defaultPlaceName
            
            let londonCoords = CLLocationCoordinate2D(latitude: 51.5072, longitude: -0.1276)
            self.mapRegion = MKCoordinateRegion(center: londonCoords, span: MKCoordinateSpan(latitudeDelta: 0.2, longitudeDelta: 0.2))
        } catch {
            print("Error loading weather: \(error)")
        }
    }

    // Main Logic: Handles searching by name
    func loadLocation(byName name: String) async throws {
        // Sets loading state, then attempts to load data for the given place name.
        self.isLoading = true
        defer { self.isLoading = false }
        
        guard networkMonitor.isConnected else {
            appError = .noInternetConnection
            return
        }
        
        // Check DB first to see if we already saved this place.
        // This prevents duplicate entries for the same city.
        let descriptor = FetchDescriptor<Place>(
            predicate: #Predicate { $0.name.localizedStandardContains(name) }
        )
        // check the local database first before making a network call.
        // This approach saves API calls and improves performance when we are revisiting.
        if let existingPlace = try? context.fetch(descriptor).first {
            print("Found \(existingPlace.name) in storage. Loading locally...")
            // Load from DB + Show "Loaded from Storage" alert
            await loadLocation(fromPlace: existingPlace, showAlert: true)
           
            await MainActor.run {
                self.storageAlertMessage = "The location '\(existingPlace.name)' was loaded from local storage."
                self.showStorageAlert = true
            }
            return
            
        }
        // If Not Found, fetch from API (New Location)
        do {
            // Geocode to get Coords
            let coords = try await locationManager.geocodeAddress(name)
            
            // Save new Place to DB
            let newPlace = Place(name: coords.name, latitude: coords.lat, longitude: coords.lon)
            context.insert(newPlace)
            try context.save()
            
            print("Saved \(coords.name) to the database!")
            
            // Update UI list instantly
            self.visited.insert(newPlace, at: 0)
            
            // Load Weather & POIs
            try await loadAll(for: newPlace)
            
            // Update Map Region
            let location2D = CLLocationCoordinate2D(latitude: coords.lat, longitude: coords.lon)
            self.mapRegion = MKCoordinateRegion(center: location2D, span: MKCoordinateSpan(latitudeDelta: 0.2, longitudeDelta: 0.2))
        } catch {
            print("ERROR: \(error)")
            await revertToDefaultWithAlert(message: "Could not find location '\(name)'. Please check spelling.")
        }
    }

    // Logic: Loads data for a known Place object
    func loadLocation(fromPlace place: Place, showAlert: Bool = true) async{
        self.isLoading = true
        defer { self.isLoading = false }
        
        guard networkMonitor.isConnected else {
            appError = .noInternetConnection
            return
        }
        
        do{
            try await loadAll(for: place)
            if showAlert {
                self.storageAlertMessage = "The location '\(place.name)' was loaded from local storage."
                self.showStorageAlert = true
            }
        } catch {
            await revertToDefaultWithAlert(message: "Could not refresh data for \(place.name).")
        }
    }

    private func revertToDefaultWithAlert(message: String) async {
        // Sets an `appError` with the given message, then calls `loadDefaultLocation()` to switch back to the default.
        self.appError = .missingData(message: message)
        await loadDefaultLocation()
    }
    
    // Updates the map camera
    func focus(on coordinate: CLLocationCoordinate2D, zoom: Double = 0.02) {
        // Animates the map region to center on the given coordinate with a specified zoom level (span).
        withAnimation{
            self.mapRegion = MKCoordinateRegion(
                center: coordinate,
                span: MKCoordinateSpan(latitudeDelta: zoom, longitudeDelta: zoom)
            )
        }
    }
    
    // Helper to fetch everything (Weather + POIs)
    private func loadAll(for place: Place) async throws {
        // Sets `activePlaceName` and prints a loading message.
        self.activePlaceName = place.name
        print("Loading data for \(place.name)...")
        
        // Always refreshes weather data from the API.
        let weatherData = try await weatherService.fetchWeather(lat: place.latitude, lon: place.longitude)
        self.currentWeather = weatherData
        
        // Checks if the `Place` object has existing annotations (POIs).
        if let existingPois = place.pois, !existingPois.isEmpty {
            print("Using POIs from cache for \(place.name)")
            
            // If annotations exist, uses the cached list for `self.pois`.
            self.pois = existingPois
        }else{
            // If annotations are empty, fetches new POIs via `MKLocalSearch`, converts them to `AnnotationModel`s, adds them to the `Place`, saves the context, and sets `self.pois`.
            print("Fetching new POIs")
            let newAnnotations = try await locationManager.findPOIs(lat: place.latitude, lon: place.longitude, limit: 5)
            place.pois = newAnnotations
            self.pois = newAnnotations
            try context.save()
        }
        
        let coordinateRegion = CLLocationCoordinate2D(latitude: place.latitude, longitude: place.longitude)
        // Calls `focus(on:zoom:)` to update the map view.
        focus(on: coordinateRegion)
        
        // Ensures the place is at the top of the `visited` list (if not already).
        place.lastUsedAt = Date()
        try? context.save()
        
        if let results = try? context.fetch(FetchDescriptor<Place>(sortBy: [SortDescriptor(\Place.lastUsedAt, order: .reverse)])) {
            self.visited = results
        }
    }

    // Handles swipe-to-delete
    func delete(at offsets: IndexSet) {
        for index in offsets {
            let placeToDelete = visited[index]
            context.delete(placeToDelete)
        }
        visited.remove(atOffsets: offsets)
        try? context.save()
    }
    

}
