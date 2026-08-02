//
//  PassportMockPhotos.swift
//  InTouch
//
//  Mock photo counts, until a real photo model exists.
//
//  ⚠️ THIS IS THE CURRENT USER'S TABLE, AND ONLY THE CURRENT USER'S. It used to
//  be a global `count(for city:)` that switched on the city NAME — a per-CITY
//  oracle standing in for a per-HOLDER fact, so any two holders who had both
//  been to Oslo would each have been credited with its 8 photos. That was
//  flagged at `f6a5df3` and again in `PassportContents`' header, and it stopped
//  being hypothetical the moment a second holder got a record. A holder's photo
//  counts now live on their own `PassportContents`; this is the one such table
//  that is hand-authored, because the current user has no posts to derive from.
//
//  THE NAME NOW DESCRIBES LESS THAN IT DID — it reads as a global mock and is a
//  single holder's fixture. A rename means renaming the file too (one type per
//  file, CLAUDE.md), one commit after this file was moved, which would make the
//  move look like a mistake it was not. Logged as a cosmetic task, not taken
//  here — the same call `b38dc21` made about `PassportHolder` naming a formatter.
//
//  THE COUNTS ARE UNCHANGED AND THAT IS THE COMMIT'S WHOLE CONDITION: Zürich 3,
//  Berlin 1, London 2, Lisbon 4, Vienna 5, Milan 6, Oslo 8, totalling 29 — the
//  same seven the switch answered, re-derived offline old-beside-new before the
//  code was touched. The counts are chosen deliberately so all six collage
//  templates (1/2/3/4/5/6+) are visible across these cities, rather than falling
//  out of whatever the mock entries happen to be. Oslo's 8 exercises the 6+
//  template's clamping.
//
//  ⚠️ THE `default: 3` IS GONE, and that is the one behaviour that changed.
//  A city absent from this table now answers 0, not 3 — see
//  `PassportContents.photoCount(for:)` for why 0 is the truthful answer and why
//  no holder that exists can reach it.
//

import Foundation

enum PassportMockPhotos {

    /// The current user's photos per city, keyed by `PassportCity.name`
    /// (which IS `PassportCity.id`).
    ///
    /// READ BY KEY LOOKUP ONLY, NEVER ITERATED — see the note on
    /// `PassportContents.totalPhotoCount`.
    static let currentUser: [String: Int] = [
        "Zürich": 3,
        "Berlin": 1,
        "London": 2,
        "Lisbon": 4,
        "Vienna": 5,
        "Milan":  6,
        "Oslo":   8,
    ]
}
