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
//  In daylight every slot carries a 3pt Bauhaus frame — ONE colour per page,
//  hashed stably from the page seed, so a city always frames in the same
//  colour (a mixed set reads as "one cell highlighted": the register's
//  yellow is far brighter than its blue). Under UV the frames give way to
//  the quiet teal edge — frames are daylight objects; after dark the
//  printing is the page's colour.
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

    /// One Bauhaus frame colour per page, stable forever for this seed.
    private var pageFrame: Color {
        var rng = SeededGenerator(seed: seed + "/frame")
        return Color.bauhausFrames[Int(rng.next() % UInt64(Color.bauhausFrames.count))]
    }

    var body: some View {
        // The collage sits over the standard printing, which runs
        // CONTINUOUSLY beneath the whole page — through the gutters, the bare
        // regions of sparse templates, and the translucent photo slots alike.
        PassportPage(security: .standard, seed: seed) {
            ZStack {
                let rects = CollageTemplate.rects(photoCount: photoCount)
                ForEach(Array(rects.enumerated()), id: \.offset) { _, rect in
                    PassportPhotoSlot(isUV: isUV, frame: pageFrame)
                        .frame(width: rect.width, height: rect.height)
                        .referenceOrigin(x: rect.minX, y: rect.minY)
                }
            }
        }
    }
}

/// A photo slot. In daylight: a neutral placeholder (until the photo model
/// exists) inside its Bauhaus frame. After dark: photographs don't fluoresce —
/// the slot sinks dark, clearly unlit against artwork that IS lit, with only
/// the quiet teal edge.
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
    /// The slot's daylight Bauhaus frame colour.
    var frame: Color

    /// The dark-wash strength over a real photograph after dark, decided in
    /// the UV pass by A/B (0.35 read as day-lit sky — photos looked LIT;
    /// 0.72 swallowed the image; 0.50 is visible, recognisable, obviously
    /// not glowing). Applies when the photo model lands; the placeholder
    /// below uses its own dimmer fill meanwhile.
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
