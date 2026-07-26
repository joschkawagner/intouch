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
//  HISTORY, because the file has been in three places. It was file-private in
//  PassportCollageView.swift; P2b-3 lifted it to Core/Components/ predicting
//  the ID card would reuse it; the card's portrait plate turned out to share
//  only ONE of its five visual aspects (see the DECISIONS.md correction), so it
//  came back here. It has exactly one consumer — PassportCollageView — and a
//  single-feature view does not belong in Core.
//
//  What IS shared with the card lives in Core/SecurityPrinting/PhotoSlotPolicy:
//  the after-dark fill and the decided uvPhotoDim constant. Policy in Core, the
//  views that apply it per-document.
//

import SwiftUI

struct PassportPhotoSlot: View {
    let isUV: Bool
    /// The slot's daylight Bauhaus frame colour.
    var frame: Color

    var body: some View {
        if isUV {
            Rectangle()
                .fill(PhotoSlotPolicy.uvFill)
                .overlay(Rectangle().strokeBorder(Color.stampTeal.opacity(0.5), lineWidth: 1.5))
        } else {
            ZStack {
                Color.muted.opacity(0.30)
                Image(systemName: "photo")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 22, height: 22)
                    .foregroundStyle(Color.text.opacity(0.30))
                    // An SF Symbol Image is an accessibility element by
                    // default, carrying the symbol's own description — the same
                    // construction that made the page-turn chevrons announce
                    // "chevron.left" before they were labelled. A city page
                    // renders one slot per cell, so without this a VoiceOver
                    // user swiping the spread hits a run of elements each
                    // announcing "photo": noise standing in for content that
                    // does not exist yet.
                    //
                    // ⚠️ THIS HIDES THE PLACEHOLDER, NOT PHOTOGRAPHS. When the
                    // real photo model lands, a photo in a city page IS content
                    // and wants a LABEL ("Zürich, 19 July"), not this modifier.
                    // Do not carry the hiding forward onto real images.
                    //
                    // Daylight branch only, deliberately: the UV branch is a
                    // bare Rectangle, and shapes are not accessibility elements,
                    // so there is nothing there to hide. (Worth noticing that
                    // the slot's accessibility footprint therefore differs by
                    // lighting mode — silent under UV, noisy by day. This
                    // equalises it downward.)
                    .accessibilityHidden(true)
            }
            .overlay(Rectangle().strokeBorder(frame, lineWidth: 3))
        }
    }
}
