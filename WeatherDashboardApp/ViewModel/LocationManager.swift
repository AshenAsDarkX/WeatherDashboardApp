//
//  LocationManager.swift
//  WeatherDashboardTemplate
//
//  Created by ashen himeshana.
//

import Foundation
import CoreLocation
@preconcurrency import MapKit

@MainActor
final class LocationManager {

    // Converts a text input (e.g., "Paris") into Lat/Lon coordinates.
    func geocodeAddress(_ address: String) async throws -> (name: String, lat: Double, lon: Double) {
        // Uses `CLGeocoder` to convert a string address into geographic coordinates.
        // Extracts the name, latitude, and longitude from the first resulting placemark.
        // Throws a `WeatherMapError.geocodingFailed` if no valid location can be found.
        let geocoder = CLGeocoder()
        do {
            // Attempt to find the location
            let placemarks = try await geocoder.geocodeAddressString(address)
                
            // Check if we got a valid result
            guard let placemark = placemarks.first,
            let location = placemark.location else {
                throw WeatherMapError.geocodingFailed(address)
            }
                
            // Prefer the locality (city name), fallback to name, then original input
            let placeName = placemark.locality ?? placemark.name ?? address
            return (name: placeName, lat: location.coordinate.latitude, lon: location.coordinate.longitude)
                
            } catch {
                // Wrap generic system errors into our custom error type
                throw WeatherMapError.geocodingFailed(address)
            }
    }

    // Searches for "Tourist Attractions" nearby using Apple Maps data.
    func findPOIs(lat: Double, lon: Double, limit: Int = 5) async throws -> [AnnotationModel] {
        // Uses `MKLocalSearch` to find Points of Interest (POIs), specifically "Tourist Attractions," within a small region around the given latitude and longitude.
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = "tourist attractions"
        
        // Define a small region around the city to search in
        let center = CLLocationCoordinate2D(latitude: lat, longitude: lon)
        request.region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1))
        
        // Executes the search request.
        let search = MKLocalSearch(request: request)
        let response = try await search.start()
        
        // Convert the raw map items into our AnnotationModel
        let places = response.mapItems.compactMap { item -> AnnotationModel? in
            guard let name = item.name else { return nil }
            return AnnotationModel(
                name: name,
                latitude: item.placemark.coordinate.latitude,
                longitude: item.placemark.coordinate.longitude
            )
        }
        
        // Return just the top X results
        return Array(places.prefix(limit))
    }
}
