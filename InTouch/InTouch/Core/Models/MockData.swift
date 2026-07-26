//
//  MockData.swift
//  InTouch
//
//  Phase 0 fixtures. No network, no database — just enough to see the shape of
//  the app.
//
//  Everything fake lives in this one file on purpose: when Supabase lands, this
//  file is deleted and the compiler points at every place that depended on it.
//

import Foundation
import CoreGraphics

enum MockData {

    // MARK: - Passport
    //
    // A city is where you have photos. `cities` drives the map pins + the city
    // count; `entries` drives the calendar rows + the photo count. Every city has
    // at least one entry, so both counts stay honest. Coordinates are real so the
    // pins land where they should on a printed atlas.

    static let zurich = PassportCity(name: "Zürich", country: "CH", latitude: 47.3769, longitude: 8.5417)
    static let berlin = PassportCity(name: "Berlin", country: "DE", latitude: 52.5200, longitude: 13.4050)
    static let london = PassportCity(name: "London", country: "GB", latitude: 51.5074, longitude: -0.1278)
    static let lisbon = PassportCity(name: "Lisbon", country: "PT", latitude: 38.7223, longitude: -9.1393)
    static let vienna = PassportCity(name: "Vienna", country: "AT", latitude: 48.2082, longitude: 16.3738)
    static let milan  = PassportCity(name: "Milan",  country: "IT", latitude: 45.4642, longitude: 9.1900)
    static let oslo   = PassportCity(name: "Oslo",   country: "NO", latitude: 59.9139, longitude: 10.7522)

    /// One pin per city on the map. Ordered; count is the "cities" number.
    static let cities: [PassportCity] = [zurich, berlin, london, lisbon, vienna, milan, oslo]

    /// One photo/moment per entry. Newest-first is a display concern — the
    /// calendar lens sorts by date, so the source order here doesn't matter.
    static let entries: [PassportEntry] = [
        PassportEntry(id: "entry-zurich-01", city: zurich, date: date(2026, 3, 14)),
        PassportEntry(id: "entry-zurich-02", city: zurich, date: date(2026, 4, 2)),
        PassportEntry(id: "entry-zurich-03", city: zurich, date: date(2026, 7, 19)),
        PassportEntry(id: "entry-berlin-01", city: berlin, date: date(2026, 4, 27)),
        PassportEntry(id: "entry-berlin-02", city: berlin, date: date(2026, 6, 1)),
        PassportEntry(id: "entry-london-01", city: london, date: date(2026, 5, 20)),
        PassportEntry(id: "entry-london-02", city: london, date: date(2026, 7, 14)),
        PassportEntry(id: "entry-lisbon-01", city: lisbon, date: date(2026, 5, 9)),
        PassportEntry(id: "entry-vienna-01", city: vienna, date: date(2026, 6, 18)),
        PassportEntry(id: "entry-milan-01",  city: milan,  date: date(2026, 1, 22)),
        PassportEntry(id: "entry-milan-02",  city: milan,  date: date(2026, 7, 4)),
        PassportEntry(id: "entry-oslo-01",   city: oslo,   date: date(2026, 2, 11)),
        PassportEntry(id: "entry-oslo-02",   city: oslo,   date: date(2026, 7, 5)),
    ]

    // MARK: - Friends feed
    //
    // Built from the real sample filenames. A post with more than one photo is a
    // carousel; the numbered files (ski-1/ski-2 …) group into one post. Newest first —
    // the feed renders this array in order, no algorithm.

    static let posts: [FeedPost] = [
        FeedPost(id: "post-ski", author: "Nora", caption: "Top lift, empty run, blue sky. No notes.",
                 city: "Verbier", date: date(2026, 7, 21, hour: 14, minute: 20),
                 photos: ["ski-1", "ski-2"]),
        FeedPost(id: "post-mountaineering", author: "Emil", caption: "On the ridge before the sun cleared it.",
                 city: "Zermatt", date: date(2026, 7, 20, hour: 6, minute: 5),
                 photos: ["mountaineering-1", "mountaineering-2"]),
        FeedPost(id: "post-cooking", author: "Sam", caption: "First real meal I've cooked all week.",
                 city: "Zürich", date: date(2026, 7, 19, hour: 20, minute: 40),
                 photos: ["cooking"]),
        FeedPost(id: "post-sea", author: "Juno", caption: "Colder than it looked. Went in anyway.",
                 city: "Hvar", date: date(2026, 7, 18, hour: 16, minute: 12),
                 photos: ["sea"]),
        FeedPost(id: "post-newyork", author: "Drew", caption: "Two parks, one very long walk.",
                 city: "New York", date: date(2026, 7, 16, hour: 19, minute: 30),
                 photos: ["new-york-1", "new-york-2"]),
        FeedPost(id: "post-london", author: "Ada", caption: "Missed the last bus. In the rain. Again.",
                 city: "London", date: date(2026, 7, 14, hour: 23, minute: 15),
                 photos: ["london"]),
        FeedPost(id: "post-cycling", author: "Sam", caption: "73 km before breakfast. Ask me why.",
                 city: "Zürich", date: date(2026, 7, 12, hour: 7, minute: 50),
                 photos: ["cycling"]),
        FeedPost(id: "post-track", author: "Nora", caption: "Lane four. Didn't win. Didn't fall.",
                 city: "Zürich", date: date(2026, 7, 10, hour: 18, minute: 0),
                 photos: ["track"]),
        FeedPost(id: "post-stadium", author: "Emil", caption: "Three hours early for a seat this good.",
                 city: "Dublin", date: date(2026, 7, 7, hour: 15, minute: 45),
                 photos: ["stadium"]),
        FeedPost(id: "post-drew", author: "Drew", caption: "New fit. Subzero field test passed.",
                 city: "Oslo", date: date(2026, 7, 5, hour: 12, minute: 30),
                 photos: ["drew-joiner"]),
    ]

    // MARK: - Collages
    //
    // Hand-placed scraps. Every position is a 0…1 fraction of the collage bounds and
    // every scale a fraction of its width, so these compose identically on any phone
    // (see Collage.swift). Photos are the real sample assets — swap the asset names to
    // recompose. This is the one place collage fixtures live.

    /// ⚠️ ORPHANED IN PRACTICE, BUT NOT SAFELY DELETABLE — flagged, not removed.
    ///
    /// Nothing renders the *current user's* collage any more: your own profile is
    /// an ID card as of f09c2eb (see DECISIONS.md 2026-07-26). But `UserProfile
    /// .collage` is still LIVE production code — `ScanResultView` renders
    /// `p.collage` for a scanned person — and the property is non-optional, so
    /// `currentUser` below must supply a value that simply never reaches a screen
    /// (you never scan yourself). Deleting this therefore means making `collage`
    /// optional, which is a model change and not a cleanup. Do that deliberately
    /// or not at all. Contrast `groupCollage`, which has no consumer whatsoever.
    static let currentUserCollage = Collage(
        ownerId: "user-me",
        aspectRatio: 0.82,
        background: .paper,
        items: [
            CollageItem(id: "me-tape",   content: .tape,                position: CGPoint(x: 0.34, y: 0.07), rotation: -8, scale: 0.34, zIndex: 4),
            CollageItem(id: "me-badge",  content: .sticker(.badge("ZÜRICH")), position: CGPoint(x: 0.68, y: 0.15), rotation: 6, scale: 0.42, zIndex: 5),
            CollageItem(id: "me-p1",     content: .photo("ski-1"),      position: CGPoint(x: 0.33, y: 0.31), rotation: -6, scale: 0.5,  zIndex: 1),
            CollageItem(id: "me-p2",     content: .photo("new-york-2"), position: CGPoint(x: 0.66, y: 0.5),  rotation: 7,  scale: 0.46, zIndex: 2),
            CollageItem(id: "me-star",   content: .sticker(.star),      position: CGPoint(x: 0.14, y: 0.52), rotation: 0,  scale: 0.12, zIndex: 6),
            CollageItem(id: "me-p3",     content: .photo("sea"),        position: CGPoint(x: 0.42, y: 0.71), rotation: -3, scale: 0.52, zIndex: 3),
            CollageItem(id: "me-ring",   content: .sticker(.ring),      position: CGPoint(x: 0.81, y: 0.8),  rotation: 0,  scale: 0.26, zIndex: 5),
            CollageItem(id: "me-text",   content: .text("the long\nway round"), position: CGPoint(x: 0.29, y: 0.92), rotation: -4, scale: 0.08, zIndex: 6),
        ]
    )

    static let scannedPersonCollage = Collage(
        ownerId: "user-emil",
        aspectRatio: 0.82,
        background: .aged,
        items: [
            CollageItem(id: "em-p1",    content: .photo("drew-joiner"), position: CGPoint(x: 0.3,  y: 0.28), rotation: 5,  scale: 0.5,  zIndex: 1),
            CollageItem(id: "em-p2",    content: .photo("london"),  position: CGPoint(x: 0.65, y: 0.44), rotation: -7, scale: 0.48, zIndex: 2),
            CollageItem(id: "em-heart", content: .sticker(.heart),  position: CGPoint(x: 0.8,  y: 0.2),  rotation: 0,  scale: 0.14, zIndex: 5),
            CollageItem(id: "em-p3",    content: .photo("cooking"), position: CGPoint(x: 0.38, y: 0.66), rotation: 3,  scale: 0.5,  zIndex: 3),
            CollageItem(id: "em-tape",  content: .tape,             position: CGPoint(x: 0.7,  y: 0.7),  rotation: 10, scale: 0.3,  zIndex: 4),
            CollageItem(id: "em-badge", content: .sticker(.badge("EMIL")), position: CGPoint(x: 0.34, y: 0.86), rotation: -5, scale: 0.44, zIndex: 6),
            CollageItem(id: "em-text",  content: .text("berlin\n2 a.m."),  position: CGPoint(x: 0.72, y: 0.88), rotation: 6, scale: 0.07, zIndex: 6),
        ]
    )

    static let eventCollage = Collage(
        ownerId: "event-rooftop",
        aspectRatio: 1.4,
        background: .night,
        items: [
            CollageItem(id: "ev-tape",  content: .tape,             position: CGPoint(x: 0.4,  y: 0.1),  rotation: 4,  scale: 0.2,  zIndex: 4),
            CollageItem(id: "ev-badge", content: .sticker(.badge("LIVE")),  position: CGPoint(x: 0.16, y: 0.22), rotation: -8, scale: 0.24, zIndex: 5),
            CollageItem(id: "ev-p1",    content: .photo("track"),   position: CGPoint(x: 0.28, y: 0.55), rotation: -4, scale: 0.32, zIndex: 1),
            CollageItem(id: "ev-p2",    content: .photo("stadium"), position: CGPoint(x: 0.52, y: 0.48), rotation: 5,  scale: 0.3,  zIndex: 2),
            CollageItem(id: "ev-p3",    content: .photo("new-york-1"), position: CGPoint(x: 0.74, y: 0.58), rotation: -6, scale: 0.3,  zIndex: 3),
            CollageItem(id: "ev-text",  content: .text("the roof\nis open"), position: CGPoint(x: 0.62, y: 0.2), rotation: 3, scale: 0.06, zIndex: 6),
            CollageItem(id: "ev-star",  content: .sticker(.star),   position: CGPoint(x: 0.88, y: 0.26), rotation: 0,  scale: 0.08, zIndex: 6),
        ]
    )

    /// Groups get a collage too (set by a member). Unused on screen this phase —
    /// the Groups tab is still an empty state — but kept so the fixture is ready.
    static let groupCollage = Collage(
        ownerId: "group-lake-crew",
        aspectRatio: 1.2,
        background: .paper,
        items: [
            CollageItem(id: "gr-p1",    content: .photo("mountaineering-1"), position: CGPoint(x: 0.3,  y: 0.45), rotation: -5, scale: 0.34, zIndex: 1),
            CollageItem(id: "gr-p2",    content: .photo("ski-2"),   position: CGPoint(x: 0.6,  y: 0.5),  rotation: 6,  scale: 0.32, zIndex: 2),
            CollageItem(id: "gr-badge", content: .sticker(.badge("LAKE CREW")), position: CGPoint(x: 0.55, y: 0.16), rotation: -3, scale: 0.4, zIndex: 5),
            CollageItem(id: "gr-ring",  content: .sticker(.ring),   position: CGPoint(x: 0.83, y: 0.74), rotation: 0,  scale: 0.2,  zIndex: 4),
        ]
    )

    // MARK: - Profiles & the scanned strangers

    static let currentUser = UserProfile(
        id: "user-me",
        displayName: "Joschka Wagner",
        handle: "@joschka",
        cityCount: cities.count,
        collage: currentUserCollage,
        joinedDate: date(2025, 9, 1),
        bio: "Zürich. Better uphill than down."
    )

    /// What a simulated "scan a person" lands on.
    static let scannedPerson = UserProfile(
        id: "user-emil",
        displayName: "Emil Roth",
        handle: "@emil",
        cityCount: 4,
        collage: scannedPersonCollage,
        joinedDate: date(2025, 11, 12),
        bio: "Berlin, mostly. 2 a.m., usually."
    )

    /// What a simulated "scan an event" lands on.
    static let scannedEvent = EventInfo(
        id: "event-rooftop",
        name: "Rooftop Sessions",
        venue: "Kanzlei Rooftop",
        city: "Zürich",
        date: date(2026, 7, 15, hour: 22),
        collage: eventCollage
    )

    // MARK: - Helpers

    /// Fixed dates, so the mock content doesn't drift as the clock moves.
    private static func date(
        _ year: Int, _ month: Int, _ day: Int,
        hour: Int = 12, minute: Int = 0
    ) -> Date {
        var components = DateComponents()
        components.year = year
        components.month = month
        components.day = day
        components.hour = hour
        components.minute = minute
        return Calendar(identifier: .gregorian).date(from: components) ?? Date()
    }
}
