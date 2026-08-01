//
//  EventInfo.swift
//  InTouch
//
//  The little an event shows on the scan-result screen: what it is, where, when,
//  and its own collage (set by the host). The full event model — upload windows,
//  attendees, recap cards — arrives in Phase 4; this is only what a door scan needs.
//

import Foundation

struct EventInfo: Identifiable, Hashable {
    let id: String
    let name: String

    /// The room. Still a bare `String`, and deliberately so — a venue is not a
    /// city and there is no type for it. `PassportCity` would be wrong here: it
    /// carries a country code and coordinates that only make sense for a place
    /// you can put a pin on. If venues ever need identity (an events feed keyed
    /// by room, say), that is its own model, not this one borrowed.
    let venue: String

    /// Where it is — a place, not a place name.
    ///
    /// The third instance of the bare-`String`-city defect, after `FeedPost`'s
    /// two halves (`d5b6ef8`, `2e2593f`). An event's "Zürich" and
    /// `MockData.zurich` were two unrelated pieces of text about one city, so an
    /// event could not route to the map pin for the place it happens in.
    ///
    /// **Holding a city is NOT a claim that it is one of yours** — the same rule
    /// `FeedPost.city` carries. `MockData.cities` is the current user's own
    /// passport; an event's location is wherever the event is, and tapping in at
    /// a rooftop in Zürich is not what puts Zürich in your passport. See the
    /// fixture note in `MockData`.
    let city: PassportCity

    let date: Date
    let collage: Collage
}
