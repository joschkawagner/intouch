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

    @Environment(\.passportRenderMode) private var mode
    private var isUV: Bool { mode.isUV }

    /// Framed to show every pin on first appearance. Pan/zoom take over after.
    private var initialRegion: MKCoordinateRegion {
        Self.region(framing: cities)
    }

    var body: some View {
        Map(initialPosition: .region(initialRegion)) {
            ForEach(cities) { city in
                // Our own label under the pin instead of Apple's grey title,
                // so it renders in the passport's register in both modes and
                // clears the UV legibility floor.
                // NOTE: annotation content renders inside the Map view, so the
                // page-wide saturation + multiply wash dims it too — UV values
                // here are deliberately over-bright so they land at the
                // legibility floor after the wash.
                Annotation(city.name, coordinate: city.coordinate) {
                    VStack(spacing: 3) {
                        cityPin
                        Text(city.name)
                            .font(Typography.timestamp)
                            .foregroundStyle(isUV ? Color.uvVioletText : Color.text)
                            .shadow(color: isUV ? Color.uvGround : Color.paper.opacity(0.8),
                                    radius: 2)
                            .shadow(color: isUV ? Color.uvGround : .clear, radius: 1)
                    }
                }
                .annotationTitles(.hidden)
            }
        }
        // Drop Apple's points of interest so the map reads as a quiet atlas, not
        // a busy street map competing with our pins.
        .mapStyle(.standard(pointsOfInterest: .excludingAll))
        // After dark, force MapKit's dark tiles so the atlas goes to night.
        .environment(\.colorScheme, isUV ? .dark : .light)
        // Pull the saturation out of Apple's bright tiles so it reads as printed
        // atlas. Pins stay crisp through the desaturation.
        .saturation(isUV ? 0.25 : 0.4)
        // Daylight warms the tiles toward paper; UV sinks them into the ground
        // colour so only the pins fluoresce. Non-interactive so gestures pass.
        .overlay(
            Group {
                if isUV {
                    Color.uvGround.opacity(0.5).blendMode(.multiply)
                } else {
                    Color.paper.opacity(0.22).blendMode(.softLight)
                }
            }
            .allowsHitTesting(false)
        )
        // The page ground behind the tiles — after dark this page must sit on
        // the same uvGround as every other page, not paper.
        .background(isUV ? Color.uvGround : Color.paper)
    }

    /// A tiny dot pin — a struck mark, not a balloon. Ink ringed in paper by
    /// day; after dark the hot treatment: a blazing near-white violet core
    /// inside a wide violet bloom — over-bright on purpose, because the map's
    /// wash dims annotation content along with the tiles.
    private var cityPin: some View {
        Circle()
            .fill(isUV ? Color.uvVioletText : Color.ink)
            .frame(width: 14, height: 14)
            .overlay(Circle().stroke(isUV ? Color.uvGround : Color.paper, lineWidth: 2.5))
            .shadow(color: isUV ? Color.stampViolet : Color.text.opacity(0.35),
                    radius: isUV ? 1.5 : 2, x: 0, y: isUV ? 0 : 1)
            .shadow(color: isUV ? Color.stampViolet.opacity(0.95) : .clear,
                    radius: isUV ? 7 : 0)
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
