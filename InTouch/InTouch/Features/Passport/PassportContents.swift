//
//  PassportContents.swift
//  InTouch
//
//  What is actually inside one person's passport: the cities they have photos
//  in, the moments inside those cities, and the per-city photo counts the
//  collages are composed from.
//
//  This exists so `PassportBookView` stops reaching for `MockData` directly.
//  The view previously read `MockData.cities` and `MockData.entries` from
//  inside its own body and helpers, which meant "the book" and "MY book" were
//  the same object — there was no seam at which a different holder could be
//  supplied. This is that seam. It is still only ever built for the current
//  user; supplying anyone else is a later step.
//
//  ⚠️ THE PHOTO COUNTS ARE STILL THE GLOBAL MOCK. `photoCount(for:)` delegates
//  to `PassportMockPhotos`, which switches on `city.name` with a `default: 3`.
//  That is a per-CITY oracle, not a per-HOLDER one, so two holders who have both
//  been to Oslo would each be credited with its 8 photos. Routing it through
//  here does not fix that — it puts it somewhere a real photo model can replace
//  it in one place instead of two.
//
//  Lives in `Features/Passport/` because only the passport reads it today. Per
//  CLAUDE.md it moves to `Core/` the moment a second feature does — which is
//  likely when a scan result needs to hand a book to someone.
//

import Foundation

struct PassportContents {

    /// One pin per city, in book order.
    let cities: [PassportCity]

    /// Every recorded moment, across all of `cities`.
    let entries: [PassportEntry]

    /// The current user's own book — the only holder that exists so far.
    static let currentUser = PassportContents(
        cities: MockData.cities,
        entries: MockData.entries
    )

    /// The number the colophon prints.
    var cityCount: Int { cities.count }

    /// The most recent moment recorded in a city (its label date), if any.
    func latestDate(for city: PassportCity) -> Date? {
        entries.filter { $0.city == city }.map(\.date).max()
    }

    /// How many photos a city's collage composes.
    func photoCount(for city: PassportCity) -> Int {
        PassportMockPhotos.count(for: city)
    }

    /// Total photos across all cities — the honest count for the colophon,
    /// consistent with the per-city collages (mocked until a photo model exists).
    var totalPhotoCount: Int {
        cities.reduce(0) { $0 + photoCount(for: $1) }
    }
}
