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

enum MockData {

    // MARK: - Passport

    static let stamps: [Stamp] = [
        Stamp(id: "stamp-zurich-01", city: "Zürich", country: "CH",
              date: date(2026, 3, 14), kind: .firstCity),
        Stamp(id: "stamp-zurich-02", city: "Zürich", country: "CH",
              date: date(2026, 4, 2), kind: .person),
        Stamp(id: "stamp-berlin-01", city: "Berlin", country: "DE",
              date: date(2026, 4, 27), kind: .event),
        Stamp(id: "stamp-lisbon-01", city: "Lisbon", country: "PT",
              date: date(2026, 5, 9), kind: .firstCity),
        Stamp(id: "stamp-vienna-01", city: "Vienna", country: "AT",
              date: date(2026, 6, 18), kind: .person),
        Stamp(id: "stamp-milan-01", city: "Milan", country: "IT",
              date: date(2026, 7, 4), kind: .event),
    ]

    // MARK: - Friends feed

    static let posts: [FeedPost] = [
        FeedPost(id: "post-01", author: "Nora", caption: "Last train missed. Worth it.",
                 city: "Zürich", date: date(2026, 7, 19, hour: 23, minute: 40), tone: .dusk),
        FeedPost(id: "post-02", author: "Emil", caption: "Nobody photographed the good part.",
                 city: "Berlin", date: date(2026, 7, 18, hour: 2, minute: 12), tone: .harbour),
        FeedPost(id: "post-03", author: "Sam", caption: "Walked the whole lake before breakfast.",
                 city: "Zürich", date: date(2026, 7, 17, hour: 8, minute: 5), tone: .field),
        FeedPost(id: "post-04", author: "Juno", caption: "The roof was technically closed.",
                 city: "Lisbon", date: date(2026, 7, 15, hour: 21, minute: 30), tone: .amber),
    ]

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
