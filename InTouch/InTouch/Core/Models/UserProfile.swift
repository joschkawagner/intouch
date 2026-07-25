//
//  UserProfile.swift
//  InTouch
//
//  A person, as shown on a profile.
//
//  There is deliberately NO friend count here. A number attached to a human being
//  is comparable between people, which makes it a scoreboard — the mechanic
//  docs/PRD.md § 4.1 rejects. Counts belong to places and occasions, so `cityCount`
//  stays and nothing counts people. See DECISIONS.md 2026-07-25.
//

import Foundation

struct UserProfile: Identifiable, Hashable {
    let id: String
    let displayName: String
    let handle: String
    let cityCount: Int
    let collage: Collage

    /// When this person joined — shown on the passport's identity page.
    let joinedDate: Date

    /// One-line self-description, shown on the passport's identity page.
    let bio: String

    /// Up to two initials, for the avatar when there's no photo yet.
    var initials: String {
        let parts = displayName.split(separator: " ").prefix(2)
        return parts.compactMap(\.first).map(String.init).joined().uppercased()
    }
}
