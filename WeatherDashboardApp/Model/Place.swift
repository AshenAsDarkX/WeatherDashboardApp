//
//  Place.swift
//  WeatherDashboardTemplate
//
//  Created by girish lukka on 18/10/2025.
//
import SwiftData
import CoreLocation

@Model
final class Place {
    @Attribute(.unique) var id: UUID
    var name: String
    var latitude: Double
    var longitude: Double
    var lastUsedAt: Date // Used to sort the list (most recent first)
    
    // if the user deletes a 'Place' (City),
    // SwiftData automatically deletes all associated 'AnnotationModel' (POIs),(https://developer.apple.com/documentation/swiftdata/schema/relationship/deleterule-swift.enum/cascade?changes=_4)
    @Relationship(deleteRule: .cascade, inverse: \AnnotationModel.place)
    var pois: [AnnotationModel]? = []

    init(
        id: UUID = UUID(),
        name: String,
        latitude: Double,
        longitude: Double
    ) {
        self.id = id
        self.name = name
        self.latitude = latitude
        self.longitude = longitude
        self.lastUsedAt = .now
    }
}

@Model
final class AnnotationModel: Identifiable {
    var id: UUID = UUID()
    var name: String
    var latitude: Double
    var longitude: Double
    var place: Place?


    init(name: String, latitude: Double, longitude: Double) {
        self.name = name
        self.latitude = latitude
        self.longitude = longitude

    }

}
