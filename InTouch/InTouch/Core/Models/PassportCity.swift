//
//  PassportCity.swift
//  InTouch
//
//  A city where you have photos — one pin on the passport map, one entry in the
//  city count. Cities are the passport's shareable flex (a map of places you've
//  actually been), which is why they get their own type separate from the photos
//  inside them (see PassportEntry).
//
//  Coordinates are stored as plain Doubles, not CLLocationCoordinate2D, because
//  that Apple type is neither Hashable nor Equatable — and SwiftUI's ForEach and
//  Set both need those. The computed `coordinate` hands MapKit what it wants.
//

import CoreLocation

struct PassportCity: Identifiable, Hashable {
    var id: String { name }
    let name: String
    let country: String        // ISO-ish 2-letter code, e.g. "CH", "DE"
    let latitude: Double
    let longitude: Double

    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
}
