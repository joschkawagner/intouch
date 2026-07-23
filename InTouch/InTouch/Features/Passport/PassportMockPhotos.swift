//
//  PassportMockPhotos.swift
//  InTouch
//
//  Mock per-city photo counts, in-feature until a real photo model exists (out
//  of scope this build; no Core/Models changes).
//
//  The counts are chosen deliberately so all six collage templates (1/2/3/4/5/6+)
//  are visible across the mock cities in this pass, rather than falling out of
//  whatever the mock entries happen to be — so the outline-only empty-cell
//  behaviour can be judged across the full range. Oslo's 8 exercises the 6+
//  template's clamping.
//

import Foundation

enum PassportMockPhotos {
    static func count(for city: PassportCity) -> Int {
        switch city.name {
        case "Berlin": 1
        case "London": 2
        case "Zürich": 3
        case "Lisbon": 4
        case "Vienna": 5
        case "Milan":  6
        case "Oslo":   8
        default:       3
        }
    }
}
