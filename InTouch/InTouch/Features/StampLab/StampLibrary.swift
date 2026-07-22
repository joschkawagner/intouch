//
//  StampLibrary.swift
//  InTouch
//
//  ⚠️ TEMPORARY — StampLab design lab. Safe to delete with the folder.
//
//  The shared city-stamp library. New model: a stamp is NOT per-person and holds no
//  photo — like a real passport, there is ONE design per city, shared by everyone
//  who's been there. (Photos will live BEHIND the stamp, tapped through in map /
//  calendar, in a later phase.)
//
//  A shared library only earns its keep if each city's stamp is CHARACTERFUL — it
//  has to say something about the place, not just print a name in a ring. So every
//  entry is hand-tuned to feel minted for that city: its own landmark as the
//  dominant mark, its own shape, its own muted ink, and a specific subtitle (a
//  station, a terminal, an airport). They share a grammar the way real passport
//  stamps do, but no two are the same template.
//
//  `design(for:)` falls back to one clean, neutral generic design (a star, just the
//  city name) for any city not yet in the library — so every place still gets a
//  proper stamp.
//

import SwiftUI

/// A city's shared stamp design. Instances (LabStamp) add only date, wear and where
/// on the page they land.
struct CityDesign {
    let shape: StampShape
    /// The dominant central mark. `nil` → the generic neutral star.
    let landmark: Landmark?
    let ink: LabInk
    /// A specific line in the surround that grounds the place (terminal, station…).
    let subtitle: String?
}

enum StampLibrary {

    /// Hand-authored, deliberately varied across shape, ink and landmark so the page
    /// reads as a collection of distinct minted stamps, not one template repeated.
    static let designs: [String: CityDesign] = [
        "Zürich":        CityDesign(shape: .circle,           landmark: .tram,         ink: .ink,   subtitle: "TRAM · 11"),
        "London":        CityDesign(shape: .oval,             landmark: .bigBen,       ink: .night, subtitle: "UNDERGROUND"),
        "Rome":          CityDesign(shape: .circle,           landmark: .colosseum,    ink: .ink,   subtitle: "TERMINI"),
        "Paris":         CityDesign(shape: .octagon,          landmark: .eiffel,       ink: .night, subtitle: "ARRIVÉE"),
        "Sydney":        CityDesign(shape: .roundedRectangle, landmark: .operaHouse,   ink: .live,  subtitle: "CIRCULAR QUAY"),
        "New York":      CityDesign(shape: .rectangle,        landmark: .skyline,      ink: .ink,   subtitle: "JFK"),
        "Tokyo":         CityDesign(shape: .scallop,          landmark: .torii,        ink: .ink,   subtitle: "HANEDA"),
        "Pisa":          CityDesign(shape: .hexagon,          landmark: .leaningTower, ink: .cocoa, subtitle: "TORRE"),
        "Amsterdam":     CityDesign(shape: .oval,             landmark: .windmill,     ink: .night, subtitle: "CENTRAAL"),
        "San Francisco": CityDesign(shape: .hexagon,          landmark: .bridge,       ink: .night, subtitle: "GOLDEN GATE"),
        "Athens":        CityDesign(shape: .octagon,          landmark: .temple,       ink: .live,  subtitle: "ACROPOLIS"),
        "New Delhi":     CityDesign(shape: .roundedRectangle, landmark: .tajMahal,     ink: .cocoa, subtitle: "TERMINAL 3"),
    ]

    /// One clean fallback for any city not in the library: a neutral star and the name.
    static let generic = CityDesign(shape: .circle, landmark: nil, ink: .ink, subtitle: nil)

    static func design(for city: String) -> CityDesign {
        designs[city] ?? generic
    }

    /// Every library design as a stamp, for the close-up rail.
    static var allCities: [String] {
        ["Zürich", "London", "Rome", "Paris", "Sydney", "New York",
         "Tokyo", "Pisa", "Amsterdam", "San Francisco", "Athens", "New Delhi"]
    }
}
