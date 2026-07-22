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
//  Decisions worth understanding if you tweak this yourself:
//   • Ink stays MUTED. `LabInk` maps only to the palette tokens; the bright
//     saturated inks in Palette are deliberately NOT reachable here — realness
//     comes from shape, wear and density, not colour.
//   • Ink-only stamps carry a WEIGHTY centre (`InkCenter`): a bold drawn landmark,
//     an emblem, or a heavy stacked date block — so a line-art stamp holds its own
//     next to a photo stamp instead of looking pale and empty.
//   • The page is HAND-PLACED (like the MockData collages), dense but with every
//     stamp mostly visible — the passport-world.jpg target. Rotation, scale-jitter
//     and wear stay seeded from the id, so they're varied yet stable.
//   • Sizes sit in a TIGHT band and are area-equalised by shape (see StampLabView),
//     so no stamp is a centrepiece and none is an afterthought.
//

import SwiftUI

// MARK: - Ink (muted only)

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
    /// Perforated card, image filling the frame, a caption strip. (passport-stamp-2)
    case postage
    /// Photo clipped inside the shape, city arced in the ink margin. (passport-stamp-6)
    case inkFrame
}

// MARK: - The weighty centre of an ink-only stamp

/// What anchors an ink stamp's middle. Varied across the page so it never looks
/// templated. Ignored when the stamp frames a photo.
enum InkCenter {
    case landmark(Landmark)
    case emblem
    case dateBlock
}

// MARK: - The stamp

struct LabStamp: Identifiable {
    let id: String
    let shape: StampShape
    let city: String
    let country: String
    let date: Date
    var ink: LabInk = .ink
    var photo: String? = nil
    var frameStyle: FrameStyle = .inkFrame
    /// The middle of an ink-only stamp: a landmark, an emblem, or a date block.
    var center: InkCenter = .emblem
    /// Procedure word struck on the stamp (MET / ARRIVAL / EVENT…).
    var word: String? = nil
    /// Explicit wear 0…1. Kept modest so even the worn ones stay readable.
    var wear: Double? = nil

    var hasPhoto: Bool { photo != nil }
}

// MARK: - A placement on the scattered page

/// A stamp positioned on the page. Position is a 0…1 fraction of the page box and
/// `scale` its visual footprint as a fraction of the page height (area-equalised by
/// shape in StampLabView). `z` is draw order: higher tucks over lower.
struct LabPlacement: Identifiable {
    let stamp: LabStamp
    let position: CGPoint
    let scale: CGFloat
    let z: Double
    var id: String { stamp.id }
}

// MARK: - Fixtures

extension LabStamp {

    /// The scattered page: ~six rows of overlapping stamps, all eight shape families,
    /// both photo treatments, and every ink-centre kind. Dense but each stamp mostly
    /// visible. Sizes sit in a tight band (0.20–0.235); wear stays ≤ 0.5 so nothing
    /// is illegible.
    static let page: [LabPlacement] = [
        // Row 1
        place("ny",      .rectangle,        "New York",  "USA",            2026, 7, 16, .ink,   0.20, 0.10, 0.225, 1,
              photo: "new-york-1", frame: .postage, wear: 0.20),
        place("london",  .roundedRectangle, "London",    "United Kingdom", 2026, 7, 21, .cocoa, 0.55, 0.09, 0.235, 2,
              photo: "london", frame: .postage, wear: 0.20),
        place("bristol", .circle,           "Bristol",   "United Kingdom", 2026, 3, 2,  .night, 0.88, 0.12, 0.225, 3,
              center: .landmark(.bigBen), word: "ARRIVAL", wear: 0.34),
        // Row 2
        place("rome",    .circle,           "Rome",      "Italy",          2025, 12, 3, .ink,   0.14, 0.26, 0.235, 4,
              center: .landmark(.colosseum), word: "ARRIVAL", wear: 0.5),
        place("paris",   .octagon,          "Paris",     "France",         2026, 2, 22, .night, 0.42, 0.25, 0.235, 5,
              center: .landmark(.eiffel), wear: 0.28),
        place("sydney",  .roundedRectangle, "Sydney",    "Australia",      2026, 1, 20, .ink,   0.70, 0.25, 0.235, 6,
              center: .landmark(.operaHouse), wear: 0.35),
        place("berlin",  .rectangle,        "Berlin",    "Germany",        2026, 3, 6,  .night, 0.91, 0.31, 0.225, 7,
              center: .emblem, word: "EVENT", wear: 0.4),
        // Row 3
        place("verbier", .scallop,          "Verbier",   "Switzerland",    2026, 7, 1,  .night, 0.26, 0.42, 0.235, 8,
              photo: "ski-1", frame: .inkFrame, wear: 0.24),
        place("vienna",  .oval,             "Vienna",    "Austria",        2025, 10, 18,.live,  0.52, 0.41, 0.235, 9,
              center: .emblem, wear: 0.38),
        place("athens",  .octagon,          "Athens",    "Greece",         2026, 5, 30, .live,  0.78, 0.43, 0.235, 10,
              center: .landmark(.temple), wear: 0.32),
        // Row 4
        place("zermatt", .triangle,         "Zermatt",   "Switzerland",    2026, 6, 22, .ink,   0.13, 0.57, 0.235, 11,
              photo: "mountaineering-1", frame: .inkFrame, wear: 0.28),
        place("tokyo",   .scallop,          "Tokyo",     "Japan",          2026, 4, 12, .night, 0.40, 0.57, 0.235, 12,
              center: .dateBlock, wear: 0.24),
        place("sf",      .hexagon,          "San Francisco", "California",  2026, 6, 8, .night, 0.66, 0.58, 0.235, 13,
              photo: "new-york-2", frame: .inkFrame, wear: 0.25),
        place("madrid",  .oval,             "Madrid",    "España",         2025, 9, 2,  .cocoa, 0.90, 0.56, 0.225, 14,
              center: .dateBlock, wear: 0.45),
        // Row 5
        place("zurich",  .circle,           "Zürich",    "Switzerland",    2026, 7, 10, .ink,   0.22, 0.72, 0.235, 15,
              center: .emblem, word: "MET", wear: 0.26),
        place("lisbon",  .roundedRectangle, "Lisbon",    "Portugal",       2025, 11, 9, .night, 0.48, 0.72, 0.235, 16,
              center: .landmark(.bridge), word: "DEPARTURE", wear: 0.36),
        place("delhi",   .house,            "New Delhi", "India",          2026, 2, 15, .live,  0.74, 0.73, 0.235, 17,
              center: .landmark(.tajMahal), wear: 0.3),
        // Row 6
        place("dublin",  .rectangle,        "Dublin",    "Ireland",        2026, 5, 24, .cocoa, 0.16, 0.89, 0.225, 18,
              photo: "stadium", frame: .postage, wear: 0.22),
        place("milan",   .triangle,         "Milan",     "Italy",          2026, 2, 4,  .live,  0.44, 0.90, 0.235, 19,
              center: .emblem, word: "EVENT", wear: 0.42),
        place("rio",     .house,            "Rio",       "Brazil",         2026, 3, 28, .cocoa, 0.69, 0.90, 0.23, 20,
              center: .dateBlock, word: "ARRIVAL", wear: 0.4),
        place("hvar",    .circle,           "Hvar",      "Croatia",        2026, 5, 6,  .ink,   0.90, 0.86, 0.225, 21,
              photo: "sea", frame: .inkFrame, wear: 0.3),
    ]

    /// A rail of individual stamps for close-up inspection: the two photo treatments,
    /// two landmark centres, an emblem, and a date block — plus the worn Rome to
    /// confirm the distressed end is now readable.
    static let detailRail: [LabStamp] = ["lab-ny", "lab-verbier", "lab-rome",
                                         "lab-paris", "lab-berlin", "lab-tokyo"]
        .compactMap { id in page.first { $0.id == id }?.stamp }

    // MARK: - Builder

    // swiftlint:disable:next function_parameter_count
    private static func place(_ id: String, _ shape: StampShape, _ city: String, _ country: String,
                              _ year: Int, _ month: Int, _ dayOfMonth: Int, _ ink: LabInk,
                              _ x: CGFloat, _ y: CGFloat, _ scale: CGFloat, _ z: Double,
                              photo: String? = nil, frame: FrameStyle = .inkFrame,
                              center: InkCenter = .emblem, word: String? = nil, wear: Double) -> LabPlacement {
        LabPlacement(
            stamp: LabStamp(id: "lab-\(id)", shape: shape, city: city, country: country,
                            date: day(year, month, dayOfMonth), ink: ink, photo: photo,
                            frameStyle: frame, center: center, word: word, wear: wear),
            position: CGPoint(x: x, y: y), scale: scale, z: z
        )
    }

    /// Fixed dates so the fixtures never drift as the clock moves (as MockData does).
    private static func day(_ year: Int, _ month: Int, _ day: Int) -> Date {
        var components = DateComponents()
        components.year = year; components.month = month; components.day = day
        return Calendar(identifier: .gregorian).date(from: components) ?? Date()
    }
}
