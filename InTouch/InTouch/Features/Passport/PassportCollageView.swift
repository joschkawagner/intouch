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
//  In daylight every slot carries a Bauhaus frame — one colour per page,
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
    /// TEMPORARY (UV design-lab pass): sample-photo asset names to render in
    /// the slots, so template composition can be judged with real images.
    /// NOT the photo model — the design lab passes these; the real book never
    /// does. Remove with the design lab when the pass closes.
    var samplePhotos: [String] = []
    /// TEMPORARY (UV design-lab pass, A/B only): per-cell frame colours
    /// instead of one per page — kept to demonstrate the rejected variant in
    /// the lab. Remove with the design lab.
    var mixedFrames = false
    /// TEMPORARY (UV design-lab pass, A/B only): the dark-wash strength over
    /// photos after dark. The lab shows candidate levels; the picked value
    /// becomes a constant when the scaffolding is removed.
    var uvPhotoDim: Double = 0.5

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
                ForEach(Array(rects.enumerated()), id: \.offset) { index, rect in
                    PassportPhotoSlot(
                        isUV: isUV,
                        sampleImage: index < samplePhotos.count ? samplePhotos[index] : nil,
                        frame: mixedFrames
                            ? Color.bauhausFrames[index % Color.bauhausFrames.count]
                            : pageFrame,
                        uvDim: uvPhotoDim
                    )
                    .frame(width: rect.width, height: rect.height)
                    .referenceOrigin(x: rect.minX, y: rect.minY)
                }
            }
        }
    }
}

/// A photo slot. In daylight: the image (or a neutral placeholder) inside its
/// Bauhaus frame. After dark: photographs don't fluoresce — the image sinks
/// under a dark wash, clearly unlit against artwork that IS lit, with only
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
    /// TEMPORARY (UV design-lab pass): a sample asset name; nil = placeholder.
    var sampleImage: String?
    /// The slot's daylight Bauhaus frame colour.
    var frame: Color
    /// TEMPORARY (UV design-lab pass): dark-wash strength over photos.
    var uvDim: Double

    var body: some View {
        if let sampleImage {
            // TEMP: a real image in the slot, for composition judgment only.
            Image(sampleImage)
                .resizable()
                .scaledToFill()
                .frame(minWidth: 0, minHeight: 0)
                .clipped()
                .overlay(isUV ? Color.uvCell.opacity(uvDim) : nil)
                .overlay(Rectangle().strokeBorder(
                    isUV ? Color.stampTeal.opacity(0.5) : frame,
                    lineWidth: isUV ? 1.5 : 3))
        } else if isUV {
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
