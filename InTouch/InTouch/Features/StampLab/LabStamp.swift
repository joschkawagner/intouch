//
//  LabStamp.swift
//  InTouch
//
//  ⚠️ TEMPORARY — StampLab design lab. Safe to delete with the folder.
//
//  A struck INSTANCE of a city stamp. New model (see StampLibrary): stamps are
//  ink-only and shared per city — the design (shape, landmark, ink, subtitle) comes
//  from the library; an instance adds only the date it was struck, its wear, and
//  where it lands on the page. So the same city struck twice is the SAME design with
//  different wear and rotation — which the page deliberately shows (Zürich, London,
//  Rome and Paris each appear more than once).
//
//  Kept from before: ink stays MUTED; per-instance wear varies but is seeded/stable
//  and capped so every stamp stays readable; sizes sit in a tight, area-equalised
//  band; the scattered page is display-only.
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

// MARK: - The struck instance

struct LabStamp: Identifiable {
    let id: String
    let city: String
    let country: String
    let date: Date
    // Resolved from the shared library design:
    let shape: StampShape
    let landmark: Landmark?
    let ink: LabInk
    let subtitle: String?
    /// Per-instance wear 0…1. Capped low so every stamp stays readable.
    var wear: Double?

    /// Build an instance, resolving its shared design from the library.
    static func make(id: String, city: String, country: String, date: Date, wear: Double) -> LabStamp {
        let design = StampLibrary.design(for: city)
        return LabStamp(id: id, city: city, country: country, date: date,
                        shape: design.shape, landmark: design.landmark,
                        ink: design.ink, subtitle: design.subtitle, wear: wear)
    }
}

// MARK: - A placement on the scattered page

struct LabPlacement: Identifiable {
    let stamp: LabStamp
    let position: CGPoint
    let scale: CGFloat
    let z: Double
    var id: String { stamp.id }
}

// MARK: - Fixtures

extension LabStamp {

    /// The scattered page: library cities (several struck more than once to show the
    /// shared design) plus a few generic-fallback cities. Dense but each stamp mostly
    /// visible; tight, area-equalised sizes; wear ≤ 0.45 so nothing is illegible.
    static let page: [LabPlacement] = [
        // Row 1
        place("ny",        "New York",      "USA",         2026, 7, 16, 0.20, 0.10, 0.225, 1,  0.20),
        place("london",    "London",        "United Kingdom", 2026, 7, 21, 0.55, 0.09, 0.235, 2, 0.22),
        place("pisa",      "Pisa",          "Italy",       2026, 6, 2,  0.87, 0.12, 0.225, 3,  0.30),
        // Row 2
        place("rome",      "Rome",          "Italy",       2025, 12, 3, 0.14, 0.26, 0.235, 4,  0.34),
        place("paris",     "Paris",         "France",      2026, 2, 22, 0.42, 0.25, 0.235, 5,  0.26),
        place("sydney",    "Sydney",        "Australia",   2026, 1, 20, 0.70, 0.25, 0.235, 6,  0.30),
        place("amsterdam", "Amsterdam",     "Netherlands", 2025, 10, 8, 0.91, 0.31, 0.225, 7,  0.32),
        // Row 3
        place("zurich1",   "Zürich",        "Switzerland", 2026, 7, 10, 0.26, 0.42, 0.235, 8,  0.26),
        place("tokyo",     "Tokyo",         "Japan",       2026, 4, 12, 0.52, 0.41, 0.235, 9,  0.28),
        place("athens",    "Athens",        "Greece",      2026, 5, 30, 0.78, 0.43, 0.235, 10, 0.30),
        // Row 4
        place("verbier",   "Verbier",       "Switzerland", 2026, 3, 14, 0.13, 0.57, 0.235, 11, 0.34),
        place("sf",        "San Francisco", "California",  2026, 6, 8,  0.40, 0.57, 0.235, 12, 0.26),
        place("oslo",      "Oslo",          "Norway",      2026, 1, 5,  0.66, 0.58, 0.235, 13, 0.32),
        place("london2",   "London",        "United Kingdom", 2025, 9, 2, 0.90, 0.56, 0.225, 14, 0.42),
        // Row 5
        place("zurich2",   "Zürich",        "Switzerland", 2026, 4, 2,  0.22, 0.72, 0.235, 15, 0.42),
        place("delhi",     "New Delhi",     "India",       2026, 2, 15, 0.48, 0.72, 0.235, 16, 0.30),
        place("dublin",    "Dublin",        "Ireland",     2026, 5, 24, 0.74, 0.73, 0.235, 17, 0.30),
        // Row 6
        place("zermatt",   "Zermatt",       "Switzerland", 2026, 6, 22, 0.16, 0.89, 0.225, 18, 0.34),
        place("hvar",      "Hvar",          "Croatia",     2026, 5, 6,  0.44, 0.90, 0.235, 19, 0.30),
        place("rome2",     "Rome",          "Italy",       2026, 3, 28, 0.69, 0.90, 0.230, 20, 0.45),
        place("paris2",    "Paris",         "France",      2025, 11, 9, 0.90, 0.86, 0.225, 21, 0.38),
    ]

    /// The close-up rail: one crisp instance of every library city, so each design can
    /// be judged for character, plus one generic-fallback stamp.
    static let detailRail: [LabStamp] = StampLibrary.allCities.map { city in
        make(id: "rail-\(city)", city: city, country: country(for: city), date: railDate, wear: 0.24)
    } + [make(id: "rail-generic", city: "Verbier", country: "Switzerland", date: railDate, wear: 0.28)]

    // MARK: - Builders

    private static func place(_ id: String, _ city: String, _ country: String,
                              _ year: Int, _ month: Int, _ dayOfMonth: Int,
                              _ x: CGFloat, _ y: CGFloat, _ scale: CGFloat, _ z: Double,
                              _ wear: Double) -> LabPlacement {
        LabPlacement(stamp: make(id: "lab-\(id)", city: city, country: country,
                                 date: day(year, month, dayOfMonth), wear: wear),
                     position: CGPoint(x: x, y: y), scale: scale, z: z)
    }

    private static let railDate = day(2026, 6, 15)

    /// Countries for the library cities, for the close-up rail.
    private static func country(for city: String) -> String {
        [
            "Zürich": "Switzerland", "London": "United Kingdom", "Rome": "Italy",
            "Paris": "France", "Sydney": "Australia", "New York": "USA",
            "Tokyo": "Japan", "Pisa": "Italy", "Amsterdam": "Netherlands",
            "San Francisco": "California", "Athens": "Greece", "New Delhi": "India",
        ][city] ?? ""
    }

    /// Fixed dates so the fixtures never drift as the clock moves (as MockData does).
    private static func day(_ year: Int, _ month: Int, _ day: Int) -> Date {
        var components = DateComponents()
        components.year = year; components.month = month; components.day = day
        return Calendar(identifier: .gregorian).date(from: components) ?? Date()
    }
}
