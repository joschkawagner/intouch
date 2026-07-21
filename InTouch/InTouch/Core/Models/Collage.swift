//
//  Collage.swift
//  InTouch
//
//  A profile is not a contact card — it's a collage the person assembles: layered
//  photos, cut-out stickers, torn scraps of text, tape, all overlapping and
//  rotated. Events and groups get their own collage too, set by a host or member.
//
//  This file is the data model only. CollageView renders it; the editor is a later
//  phase. See docs/DESIGN.md § Collage.
//
//  THE ONE RULE THAT MATTERS: every coordinate is stored **relative** — position as
//  0…1 fractions of the collage bounds, scale as a fraction of the collage width.
//  Nothing is an absolute point. A collage laid out in absolute points would drift
//  the instant it opened on a phone of a different size; relative coordinates make
//  it compose identically everywhere.
//

import SwiftUI

struct CollageItem: Identifiable, Hashable {

    let id: String

    /// What the scrap *is*, carrying its own payload. `kind` is derived from this,
    /// so an item can never be in an impossible state (a `.text` holding a photo).
    let content: Content

    /// Centre of the scrap, as 0…1 fractions of the collage bounds. (0.5, 0.5) is
    /// dead centre; values slightly outside 0…1 let a cut-out bleed off the edge.
    let position: CGPoint

    /// Rotation off-axis, in degrees. Real collage is never square to the page.
    let rotation: Double

    /// Size as a fraction of the collage **width** (photos, stickers, tape use it as
    /// their width; text uses it as its font size relative to the width).
    let scale: CGFloat

    /// Stacking order. Higher draws on top.
    let zIndex: Double

    var kind: Kind { content.kind }

    enum Kind: Hashable { case photo, sticker, text, tape }

    /// The payload. `.photo` reuses the existing generated colour blocks (FeedPost
    /// .Tone) as a stand-in until real JPGs land — swap this case for an image
    /// reference then and the compiler will point at every render site.
    enum Content: Hashable {
        case photo(FeedPost.Tone)
        case sticker(Sticker)
        case text(String)
        case tape

        var kind: Kind {
            switch self {
            case .photo: .photo
            case .sticker: .sticker
            case .text: .text
            case .tape: .tape
            }
        }
    }

    /// A cut-out sticker. Placeholder vocabulary — simple shapes and badges — until
    /// there's real sticker art to drop in.
    enum Sticker: Hashable {
        case badge(String)   // a short word in a filled pill, e.g. "ZÜRICH"
        case star
        case heart
        case ring            // a stamp-like outline ring
    }
}

struct Collage: Hashable {

    /// Who assembled it — a user, an event, or a group.
    let ownerId: String

    /// width / height of the collage frame. Portrait profile ≈ 0.8, wide event ≈ 1.4.
    let aspectRatio: CGFloat

    let background: Background
    let items: [CollageItem]

    /// The paper the scraps are stuck onto. Palette-backed so it never introduces a
    /// raw colour.
    enum Background: Hashable {
        case paper, aged, night, ink

        var fill: Color {
            switch self {
            case .paper: .paper
            case .aged: .aged
            case .night: .night
            case .ink: .ink
            }
        }
    }
}
