//
//  UserProfile.swift
//  InTouch
//
//  A person, as shown on a profile. The collage is the hero; the rest is the
//  passport-form line beneath it — handle, and the two counts that are the whole
//  status mechanic (see docs/PRD.md § 1).
//

import Foundation

struct UserProfile: Identifiable, Hashable {
    let id: String
    let displayName: String
    let handle: String
    let friendCount: Int
    let stampCount: Int
    let collage: Collage

    /// Up to two initials, for the avatar when there's no photo yet.
    var initials: String {
        let parts = displayName.split(separator: " ").prefix(2)
        return parts.compactMap(\.first).map(String.init).joined().uppercased()
    }
}
