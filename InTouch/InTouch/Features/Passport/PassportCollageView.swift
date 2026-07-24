//
//  PassportCollageView.swift
//  InTouch
//
//  The right page of a city spread — the auto-composed photo collage (design
//  2c). Picks a template by photo count and fills it: every cell is a photo
//  slot (rendered as a neutral placeholder until the photo model exists).
//  There is no empty-cell concept — a city with N photos gets an N-cell
//  template, and on sparse pages the rest is bare printed page, the security
//  printing showing through as the composition. Laid out in the 232×330
//  reference page so the design's cell rects map 1:1.
//
//  This is deliberately the *opposite* of Core/Components/CollageView, the
//  hand-assembled profile collage — here the app composes a Mondrian grid.
//

import SwiftUI

struct PassportCollageView: View {

    let photoCount: Int
    /// Stable identity for this page's printing geometry (the city's collage).
    var seed: String = "collage"

    @Environment(\.passportRenderMode) private var mode
    private var isUV: Bool { mode.isUV }

    var body: some View {
        // The collage sits over the standard printing, which runs
        // CONTINUOUSLY beneath the whole page — through the gutters, the bare
        // regions of sparse templates, and the translucent photo slots alike.
        PassportPage(security: .standard, seed: seed) {
            ZStack {
                let rects = CollageTemplate.rects(photoCount: photoCount)
                ForEach(Array(rects.enumerated()), id: \.offset) { _, rect in
                    PassportPhotoSlot(isUV: isUV)
                        .frame(width: rect.width, height: rect.height)
                        .referenceOrigin(x: rect.minX, y: rect.minY)
                }
            }
        }
    }
}

/// A stand-in for a photo until the photo model exists. In daylight: a soft
/// neutral field with a faint photo glyph. After dark: dark and non-reactive
/// (photographs don't fluoresce) with only a faint teal edge.
///
/// The fill is translucent in BOTH modes — the security printing runs
/// continuously beneath the whole page and shows through the slot, dimmed.
/// One object: the printing is on the page, it doesn't stop where a photo
/// begins. Real passports print security linework straight across the
/// portrait (anti-substitution) — the Swiss UV reference shows contours
/// crossing the photo — so when real photos land, a subdued overprint across
/// them is the authentic continuation of this rule.
private struct PassportPhotoSlot: View {
    let isUV: Bool
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
        }
    }
}

#Preview {
    HStack(spacing: 12) {
        PassportCollageView(photoCount: 1, seed: "preview")
            .frame(width: 232, height: 330)
            .environment(\.passportRenderMode, .daylight)
        PassportCollageView(photoCount: 1, seed: "preview")
            .frame(width: 232, height: 330)
            .environment(\.passportRenderMode, .uv)
    }
    .padding()
    .background(Color.muted)
}
