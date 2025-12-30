//
//  LocationManager.swift
//  WeatherDashboardTemplate
//
//  Created by girish lukka on 18/10/2025.
//

import Foundation
import CoreLocation
@preconcurrency import MapKit


@MainActor
final class LocationManager {

    func geocodeAddress(_ address: String) async throws -> (name: String, lat: Double, lon: Double) {
        // Uses `CLGeocoder` to convert a string address into geographic coordinates.
        // Extracts the name, latitude, and longitude from the first resulting placemark.
        // Throws a `WeatherMapError.geocodingFailed` if no valid location can be found.
        let geocoder = CLGeocoder()
        do {
                // 1. Perform the Geocoding
                let placemarks = try await geocoder.geocodeAddressString(address)
                
                // 2. Validate we got a result
                guard let placemark = placemarks.first,
                      let location = placemark.location else {
                    throw WeatherMapError.geocodingFailed(address)
                }
                
                // 3. Extract a clean name
                // We prefer the city name (locality) -> then the place name -> then the original input
                let placeName = placemark.locality ?? placemark.name ?? address
                
                return (name: placeName, lat: location.coordinate.latitude, lon: location.coordinate.longitude)
                
            } catch {
                // 4. Wrap any system errors in your custom error
                throw WeatherMapError.geocodingFailed(address)
            }
        // DUMMY RETURN TO SATISFY COMPILER
//        preconditionFailure("Stubbed function not implemented. Requires a (name: String, lat: Double, lon: Double) return.")
    }

    func findPOIs(lat: Double, lon: Double, limit: Int = 5) async throws -> [AnnotationModel] {
        // Uses `MKLocalSearch` to find Points of Interest (POIs), specifically "Tourist Attractions," within a small region around the given latitude and longitude.
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = "tourist attractions"
        
        let center = CLLocationCoordinate2D(latitude: lat, longitude: lon)
        request.region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1))
        // Executes the search request.
        let search = MKLocalSearch(request: request)
        let response = try await search.start()
        // Maps the `MKMapItem` results into an array of `AnnotationModel`s, filtering out any without a name.
        let places = response.mapItems.compactMap { item -> AnnotationModel? in
                    guard let name = item.name else { return nil }
                    return AnnotationModel(
                        name: name,
                        latitude: item.placemark.coordinate.latitude,
                        longitude: item.placemark.coordinate.longitude
                    )
                }
        // Limits the final array size to the specified `limit`.
        return Array(places.prefix(limit))
        // DUMMY RETURN TO SATISFY COMPILER
//        preconditionFailure("Stubbed function not implemented. Requires a [AnnotationModel] return.")
    }
}
