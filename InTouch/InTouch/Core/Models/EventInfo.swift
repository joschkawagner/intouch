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
    let venue: String
    let city: String
    let date: Date
    let collage: Collage
}
