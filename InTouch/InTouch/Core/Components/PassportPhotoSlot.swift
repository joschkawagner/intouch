//
//  PassportPhotoSlot.swift
//  InTouch
//
//  A photo slot. In daylight: a neutral placeholder (until the photo model
//  exists) inside its Bauhaus frame. After dark: photographs don't fluoresce —
//  the slot sinks dark, clearly unlit against artwork that IS lit, with only
//  the quiet teal edge.
//
//  The fill is translucent in BOTH modes — the security printing runs
//  continuously beneath the whole page and shows through the slot, dimmed.
//  One object: the printing is on the page, it doesn't stop where a photo
//  begins. Real passports print security linework straight across the
//  portrait (anti-substitution) — the Swiss UV reference shows contours
//  crossing the photo — so when real photos land, a subdued overprint across
//  them is the authentic continuation of this rule.
//
//  Lifted out of PassportCollageView.swift (where it was file-private) when
//  the ID card needed the same slot behaviour for its portrait plate. Moved
//  with an identical body and an unchanged call site; only the access level
//  and the file changed. The name keeps its `Passport` prefix for now —
//  renames are their own commit, as with the other Core lifts.
//

import SwiftUI

struct PassportPhotoSlot: View {
    let isUV: Bool
    /// The slot's daylight Bauhaus frame colour.
    var frame: Color

    /// The dark-wash strength over a real photograph after dark, decided in
    /// the UV pass by A/B (0.35 read as day-lit sky — photos looked LIT;
    /// 0.72 swallowed the image; 0.50 is visible, recognisable, obviously
    /// not glowing). Applies when the photo model lands; the placeholder
    /// below uses its own dimmer fill meanwhile.
    ///
    /// This is a DECIDED constant, not a tunable default. It crossed into Core
    /// as the literal it was — do not re-derive it from a Palette token or
    /// demote it to a parameter default without re-running the A/B.
    ///
    /// NOTE: it is currently unused (it applies once the photo model lands), so
    /// **no pixel gate can catch a wrong value here** — a typo would pass every
    /// screenshot comparison silently. This comment is the only guard until
    /// something renders it.
    static let uvPhotoDim: Double = 0.5

    var body: some View {
        if isUV {
            Rectangle()
                .fill(Color.uvCell.opacity(0.55))
                .overlay(Rectangle().strokeBorder(Color.stampTeal.opacity(0.5), lineWidth: 1.5))
        } else {
            ZStack {
                Color.muted.opacity(0.30)
                Image(systemName: "photo")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 22, height: 22)
                    .foregroundStyle(Color.text.opacity(0.30))
            }
            .overlay(Rectangle().strokeBorder(frame, lineWidth: 3))
        }
    }
}
