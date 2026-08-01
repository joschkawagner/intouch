//
//  UserProfile.swift
//  InTouch
//
//  A person, as shown on a profile.
//
//  THERE IS DELIBERATELY NO COUNT OF ANY KIND ON THIS TYPE, and that is two
//  separate rules that happen to land in the same place.
//
//  No friend count, and no slot that could grow one: a number attached to a
//  human being is comparable between people, which makes it a scoreboard — the
//  mechanic docs/PRD.md § 4.1 rejects. Counts belong to places and occasions.
//  The surviving legitimate count in this app is CITIES, because it counts
//  places; it lives on `PassportContents`, where the places themselves are.
//
//  And no city count either, for a different reason: `cityCount` used to be
//  stored here, duplicating `PassportContents.cityCount`. The two agreed only
//  because one fixture line wrote `cities.count` into it, and nothing enforced
//  that. A count of a person's cities is a fact about their record, not a
//  property of their profile row — in Postgres it is an aggregate over their
//  photos, exactly the kind of denormalised column that goes stale. So it is
//  derived at the one place that holds the cities.
//
//  See DECISIONS.md 2026-07-25 (the scoreboard rule) and 2026-08-02 (the
//  duplicate).
//

import Foundation

struct UserProfile: Identifiable, Hashable {
    let id: String
    let displayName: String
    let handle: String

    /// The serial printed on this person's documents — the passport's `HOLDER
    /// NO.`, the ID card's header, and the core of both MRZ bands.
    ///
    /// STORED, NEVER COMPUTED, and that is the decision rather than an
    /// implementation detail. A serial is *issued and recorded*; it is not a
    /// function of anything else about the holder. Deriving it — hashing `id`
    /// into a four-digit range was the alternative considered — fails on its own
    /// terms twice over: the range collides at around a hundred users, and the
    /// number would silently change if an `id` ever did, which is the one thing
    /// a document serial may never do. When Supabase lands this is a column, not
    /// an expression.
    ///
    /// Formatted for printing by `PassportHolder`, which is also where the rule
    /// that the printed serial and the MRZ core must agree is written down.
    let passportNumber: Int

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

    /// The name as a feed byline says it — first name only.
    ///
    /// This makes explicit a rule that used to be encoded by accident: feed posts
    /// stored a bare `"Nora"`, so the byline showed a first name because the
    /// *fixture* was a first name, not because anything decided it should be.
    /// Now that a post carries a whole person, the rule has to live somewhere,
    /// and it lives here beside `initials` — the other place a display form is
    /// derived from `displayName` rather than stored twice.
    ///
    /// Derived, never stored: a stored short name is a second source of truth for
    /// the same fact, and the two drift the first time someone edits their name.
    var shortName: String {
        String(displayName.split(separator: " ").first ?? Substring(displayName))
    }
}
