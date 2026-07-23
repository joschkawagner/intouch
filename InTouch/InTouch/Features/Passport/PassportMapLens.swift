//
//  PassportMapLens.swift
//  InTouch
//
//  The passport map: one pin per city you have photos in, on a printed-atlas
//  styled MapKit map. Pinch-zoom and pan come free from SwiftUI's Map — we just
//  don't disable them. Tapping through a pin to that city's photos is a later
//  phase; for now the pin carries the city's name as its label.
//
//  DESIGN.md § Map: "muted land, water water, pins as tiny stamps." We can't
//  fully re-skin Apple's tiles from SwiftUI, so we get most of the way there by
//  stripping POI clutter and washing the whole map toward paper, then dropping
//  ink dots on top so it reads as our object, not a raw Apple map.
//

import SwiftUI
import MapKit

struct PassportMapLens: View {

    let cities: [PassportCity]

    /// Framed to show every pin on first appearance. Pan/zoom take over after.
    private var initialRegion: MKCoordinateRegion {
        Self.region(framing: cities)
    }

    var body: some View {
        Map(initialPosition: .region(initialRegion)) {
            ForEach(cities) { city in
                Annotation(city.name, coordinate: city.coordinate) {
                    cityPin
                }
                .annotationTitles(.visible)
            }
        }
        // Drop Apple's points of interest so the map reads as a quiet atlas, not
        // a busy street map competing with our pins.
        .mapStyle(.standard(pointsOfInterest: .excludingAll))
        // Pull the saturation out of Apple's bright green land / blue water so it
        // reads as printed atlas. The ink pins are near-black, so they stay crisp
        // through the desaturation rather than washing out.
        .saturation(0.4)
        // A thin paper wash then warms the muted tiles toward the app's surface.
        // Non-interactive so it never blocks pan/zoom gestures.
        .overlay(
            Color.paper
                .opacity(0.22)
                .blendMode(.softLight)
                .allowsHitTesting(false)
        )
        // The design's guidance line on the map page. Uses a scaling chrome font
        // (not the tiny fixed 9pt of the mock) because this page renders native
        // size, not inside the reference-scaled page.
        .overlay(alignment: .bottomLeading) {
            Text(Typography.chrome("tap a pin to open that city"))
                .font(Typography.label)
                .tracking(Typography.stampTracking * 0.3)
                .foregroundStyle(Color.ink.opacity(0.5))
                .padding(14)
                .allowsHitTesting(false)
        }
    }

    /// A tiny ink dot ringed in paper — the pin as a struck mark, not a balloon.
    private var cityPin: some View {
        Circle()
            .fill(Color.ink)
            .frame(width: 14, height: 14)
            .overlay(Circle().stroke(Color.paper, lineWidth: 2.5))
            .shadow(color: Color.text.opacity(0.35), radius: 2, x: 0, y: 1)
    }

    /// Bounding box of all cities → a centred, padded region. Falls back to a
    /// wide European frame if somehow handed no cities.
    static func region(framing cities: [PassportCity]) -> MKCoordinateRegion {
        guard let first = cities.first else {
            return MKCoordinateRegion(
                center: CLLocationCoordinate2D(latitude: 48, longitude: 9),
                span: MKCoordinateSpan(latitudeDelta: 30, longitudeDelta: 30)
            )
        }

        var minLat = first.latitude, maxLat = first.latitude
        var minLon = first.longitude, maxLon = first.longitude
        for city in cities {
            minLat = min(minLat, city.latitude); maxLat = max(maxLat, city.latitude)
            minLon = min(minLon, city.longitude); maxLon = max(maxLon, city.longitude)
        }

        let center = CLLocationCoordinate2D(
            latitude: (minLat + maxLat) / 2,
            longitude: (minLon + maxLon) / 2
        )
        // 1.5× padding so pins never sit on the very edge; a floor keeps a single
        // city from zooming absurdly close.
        let span = MKCoordinateSpan(
            latitudeDelta: max((maxLat - minLat) * 1.5, 4),
            longitudeDelta: max((maxLon - minLon) * 1.5, 4)
        )
        return MKCoordinateRegion(center: center, span: span)
    }
}

#Preview {
    PassportMapLens(cities: MockData.cities)
        .paperBackground()
}
