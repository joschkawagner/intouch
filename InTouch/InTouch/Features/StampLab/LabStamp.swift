//
//  LabStamp.swift
//  InTouch
//
//  ⚠️ TEMPORARY — StampLab design lab. Safe to delete with the folder.
//
//  The lab's own stamp model plus the fixture that composes the scattered page.
//  Deliberately separate from the app's `Stamp`/`StampView.Kind` so deleting this
//  folder can't touch the shipping app.
//
//  Two decisions worth understanding if you tweak this yourself:
//   • Ink stays MUTED. `LabInk` maps only to the eight-token palette (plus the two
//     lightest tokens used sparingly for faded stamps). The bright saturated inks
//     in Palette are deliberately NOT reachable here — realness comes from shape,
//     wear and density, not colour.
//   • The page is HAND-PLACED (like the MockData collages), not randomly scattered.
//     A pure random layout buries stamps illegibly; curated positions keep it dense
//     but readable, while each stamp's rotation, scale-jitter and wear stay seeded
//     from its id so they're varied yet stable.
//

import SwiftUI

// MARK: - Ink (muted only)

/// The muted inks a lab stamp may be struck in — the app's palette tokens, nothing
/// brighter. `water`/`reseda` are the two light ones; used only for faded stamps.
enum LabInk {
    case ink, night, live, cocoa, water, reseda

    var color: Color {
        switch self {
        case .ink: .ink
        case .night: .night
        case .live: .live
        case .cocoa: .text
        case .water: .water
        case .reseda: .muted
        }
    }
}

// MARK: - Frame style (how a photo is set)

enum FrameStyle {
    /// Perforated card, image filling the frame at fuller colour, a caption strip
    /// with city + date. The postage-stamp look (passport-stamp-2.jpg).
    case postage
    /// Photo clipped inside the shape, city arced/spanning the ink margin, gently
    /// aged so it reads as printed into the passport (passport-stamp-6.jpg).
    case inkFrame
}

// MARK: - The stamp

struct LabStamp: Identifiable {
    let id: String
    let shape: StampShape
    let city: String
    let country: String
    let date: Date
    var ink: LabInk = .ink
    /// Asset name of a framed photo, or nil for a pure ink mark.
    var photo: String? = nil
    var frameStyle: FrameStyle = .inkFrame
    /// The procedure word struck across the stamp (MET / ARRIVAL / EVENT…).
    var word: String? = nil
    /// Explicit wear 0…1. `nil` lets `LabStampView` derive a seeded moderate value.
    var wear: Double? = nil

    var hasPhoto: Bool { photo != nil }
}

// MARK: - A placement on the scattered page

/// A stamp positioned on the page. Position is a 0…1 fraction of the page box and
/// `scale` is the stamp's height as a fraction of the page height — the same
/// relative-coordinate approach the collages use, so it composes on any screen.
/// `z` is draw order: higher sits on top, so the newest stamps cover the older.
struct LabPlacement: Identifiable {
    let stamp: LabStamp
    let position: CGPoint
    let scale: CGFloat
    let z: Double
    var id: String { stamp.id }
}

// MARK: - Fixtures

extension LabStamp {

    /// The scattered, overlapping page — all eight shape families, both photo
    /// treatments, a spread of muted inks and wear, a few stamps cropped by the edge.
    static let page: [LabPlacement] = [
        // — lower layer: older, fainter, partly covered —
        LabPlacement(stamp: LabStamp(id: "lab-madrid", shape: .oval, city: "Madrid", country: "España",
                                     date: day(2025, 9, 2), ink: .reseda, wear: 0.55),
                     position: .init(x: 0.70, y: 0.33), scale: 0.20, z: 1),
        LabPlacement(stamp: LabStamp(id: "lab-vienna", shape: .oval, city: "Vienna", country: "Austria",
                                     date: day(2025, 10, 18), ink: .live, wear: 0.4),
                     position: .init(x: 0.47, y: 0.49), scale: 0.21, z: 2),
        LabPlacement(stamp: LabStamp(id: "lab-lisbon", shape: .roundedRectangle, city: "Lisbon", country: "Portugal",
                                     date: day(2025, 11, 9), ink: .water, word: "DEPARTURE", wear: 0.5),
                     position: .init(x: 0.80, y: 0.87), scale: 0.22, z: 3),
        LabPlacement(stamp: LabStamp(id: "lab-rome", shape: .circle, city: "Rome", country: "Italy",
                                     date: day(2025, 12, 3), ink: .ink, word: "ARRIVAL", wear: 0.82),
                     position: .init(x: 0.84, y: 0.67), scale: 0.23, z: 4),
        LabPlacement(stamp: LabStamp(id: "lab-sydney", shape: .roundedRectangle, city: "Sydney", country: "Australia",
                                     date: day(2026, 1, 20), ink: .ink, wear: 0.35),
                     position: .init(x: 0.17, y: 0.65), scale: 0.24, z: 5),
        LabPlacement(stamp: LabStamp(id: "lab-milan", shape: .triangle, city: "Milan", country: "Italy",
                                     date: day(2026, 2, 4), ink: .live, word: "EVENT", wear: 0.45),
                     position: .init(x: 0.9, y: 0.12), scale: 0.22, z: 6),
        LabPlacement(stamp: LabStamp(id: "lab-paris", shape: .octagon, city: "Paris", country: "France",
                                     date: day(2026, 2, 22), ink: .night, wear: 0.3),
                     position: .init(x: 0.83, y: 0.43), scale: 0.22, z: 7),
        LabPlacement(stamp: LabStamp(id: "lab-berlin", shape: .rectangle, city: "Berlin", country: "Germany",
                                     date: day(2026, 3, 6), ink: .night, word: "EVENT", wear: 0.4),
                     position: .init(x: 0.5, y: 0.63), scale: 0.27, z: 8),

        // — middle layer —
        LabPlacement(stamp: LabStamp(id: "lab-rio", shape: .house, city: "Rio", country: "Brazil",
                                     date: day(2026, 3, 28), ink: .cocoa, word: "ARRIVAL", wear: 0.5),
                     position: .init(x: 0.60, y: 0.80), scale: 0.22, z: 9),
        LabPlacement(stamp: LabStamp(id: "lab-tokyo", shape: .scallop, city: "Tokyo", country: "Japan",
                                     date: day(2026, 4, 12), ink: .night, wear: 0.28),
                     position: .init(x: 0.20, y: 0.35), scale: 0.24, z: 10),
        LabPlacement(stamp: LabStamp(id: "lab-hvar", shape: .circle, city: "Hvar", country: "Croatia",
                                     date: day(2026, 5, 6), ink: .ink, photo: "sea", frameStyle: .inkFrame, wear: 0.3),
                     position: .init(x: 0.5, y: 0.93), scale: 0.23, z: 11),
        LabPlacement(stamp: LabStamp(id: "lab-dublin", shape: .rectangle, city: "Dublin", country: "Ireland",
                                     date: day(2026, 5, 24), ink: .cocoa, photo: "stadium", frameStyle: .postage, wear: 0.22),
                     position: .init(x: 0.15, y: 0.86), scale: 0.25, z: 12),

        // — top layer: newest, crispest, framed photos on top —
        LabPlacement(stamp: LabStamp(id: "lab-sanfran", shape: .hexagon, city: "San Francisco", country: "California",
                                     date: day(2026, 6, 8), ink: .night, photo: "new-york-2", frameStyle: .inkFrame, wear: 0.25),
                     position: .init(x: 0.33, y: 0.80), scale: 0.27, z: 13),
        LabPlacement(stamp: LabStamp(id: "lab-zermatt", shape: .triangle, city: "Zermatt", country: "Switzerland",
                                     date: day(2026, 6, 22), ink: .ink, photo: "mountaineering-1", frameStyle: .inkFrame, wear: 0.28),
                     position: .init(x: 0.67, y: 0.55), scale: 0.25, z: 14),
        LabPlacement(stamp: LabStamp(id: "lab-verbier", shape: .scallop, city: "Verbier", country: "Switzerland",
                                     date: day(2026, 7, 1), ink: .night, photo: "ski-1", frameStyle: .inkFrame, wear: 0.24),
                     position: .init(x: 0.36, y: 0.52), scale: 0.26, z: 15),
        LabPlacement(stamp: LabStamp(id: "lab-zurich", shape: .circle, city: "Zürich", country: "Switzerland",
                                     date: day(2026, 7, 10), ink: .ink, word: "MET", wear: 0.26),
                     position: .init(x: 0.5, y: 0.35), scale: 0.25, z: 16),
        LabPlacement(stamp: LabStamp(id: "lab-newyork", shape: .rectangle, city: "New York", country: "USA",
                                     date: day(2026, 7, 16), ink: .ink, photo: "new-york-1", frameStyle: .postage, wear: 0.2),
                     position: .init(x: 0.73, y: 0.21), scale: 0.26, z: 17),
        LabPlacement(stamp: LabStamp(id: "lab-london", shape: .roundedRectangle, city: "London", country: "United Kingdom",
                                     date: day(2026, 7, 21), ink: .cocoa, photo: "london", frameStyle: .postage, wear: 0.2),
                     position: .init(x: 0.27, y: 0.13), scale: 0.27, z: 18),
    ]

    /// A short rail of individual stamps for close-up inspection: a postage photo, an
    /// ink-frame photo in a fancy shape, a heavily distressed pure-ink mark, a crisp
    /// detailed one.
    static let detailRail: [LabStamp] = [
        LabStamp(id: "lab-newyork", shape: .rectangle, city: "New York", country: "USA",
                 date: day(2026, 7, 16), ink: .ink, photo: "new-york-1", frameStyle: .postage, wear: 0.2),
        LabStamp(id: "lab-verbier", shape: .scallop, city: "Verbier", country: "Switzerland",
                 date: day(2026, 7, 1), ink: .night, photo: "ski-1", frameStyle: .inkFrame, wear: 0.24),
        LabStamp(id: "lab-rome-worn", shape: .circle, city: "Rome", country: "Italy",
                 date: day(2025, 12, 3), ink: .ink, word: "ARRIVAL", wear: 0.9),
        LabStamp(id: "lab-tokyo", shape: .scallop, city: "Tokyo", country: "Japan",
                 date: day(2026, 4, 12), ink: .night, wear: 0.18),
    ]

    /// Fixed dates so the fixtures never drift as the clock moves (as MockData does).
    private static func day(_ year: Int, _ month: Int, _ day: Int) -> Date {
        var components = DateComponents()
        components.year = year; components.month = month; components.day = day
        return Calendar(identifier: .gregorian).date(from: components) ?? Date()
    }
}
