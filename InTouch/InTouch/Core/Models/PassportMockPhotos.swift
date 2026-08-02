//
//  PassportMockPhotos.swift
//  InTouch
//
//  Mock per-city photo counts, until a real photo model exists.
//
//  MOVED TO `Core/Models/` — A PURE MOVE, THE DECLARATION IS UNTOUCHED.
//  This header used to say the counts were "in-feature … (out of scope this
//  build; no Core/Models changes)". Both claims died at `4a3c65b`, which lifted
//  `PassportContents` into `Core/Models/` — and `PassportContents.photoCount(for:)`
//  is this enum's ONLY consumer, repo-wide. So a `Core` file was reaching into
//  `Features/Passport/`, which is the dependency direction CLAUDE.md's structure
//  rule exists to prevent, and which the plan for that commit had explicitly
//  called "worse than the move, not a way of dodging it" about a different file.
//  It landed anyway, in the other direction, and nothing caught it. Same shape as
//  `PassportHolder`'s stale header (corrected at `b38dc21`): a comment asserting a
//  boundary the file had already crossed.
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
