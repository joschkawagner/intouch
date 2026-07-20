//
//  FeedPost.swift
//  InTouch
//
//  A post in the friends feed: one photo, one line of caption.
//

import SwiftUI

struct FeedPost: Identifiable, Hashable {
    let id: String
    let author: String
    let caption: String
    let city: String
    let date: Date

    /// Stand-in for the photo until real uploads land in Phase 3.
    let tone: Tone

    /// A placeholder "photo" rendered as a duotone block.
    ///
    /// Temporary. DESIGN.md's rule is that photos carry the colour and the
    /// interface stays in the eight tokens — these blocks only exist so the
    /// feed has the right rhythm before there are real images. They delete
    /// along with MockData.
    enum Tone: Hashable {
        case dusk, field, harbour, amber

        var colours: [Color] {
            switch self {
            case .dusk: [.night, .ink]
            case .field: [.live, .muted]
            case .harbour: [.water, .night]
            case .amber: [.aged, .muted]
            }
        }

        var symbol: String {
            switch self {
            case .dusk: "moon.stars"
            case .field: "leaf"
            case .harbour: "water.waves"
            case .amber: "sun.horizon"
            }
        }
    }
}
