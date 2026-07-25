//
//  IDCardPrinting.swift
//  InTouch
//
//  The security printing beneath the ID card's fields — the card's counterpart
//  to SecurityPrinting, composed from the same Core primitives against a
//  different geometry.
//
//  WHY THIS IS NOT SecurityPrinting: that view's composition is authored in the
//  page's 232×330 and fits by min(w/232, h/330). Handed a 539×340 card it
//  scales to 1.03 and its elements land wrong — the horizontal microprint row
//  centres at x ≈ 119 instead of mid-card, the rosette sits off the page. The
//  primitives are shared; the composition is per-document, and always will be.
//
//  ONE OBJECT, TWO LIGHTING STATES, exactly as the book: every element exists
//  identically in both modes and only the lighting differs. Daylight prints the
//  whole layer in the one subtle `ink` at whisper opacities; UV gives each zone
//  its hue — teal/forest terrain, gold microprint and marks, violet rosette
//  lace, a red keyline. Never fork the geometry between modes.
//
//  ⚠️ NOT YET VERIFIED. Xcode Previews use a different rendering path from the
//  simulator, so nothing here counts as verified until it has run in the sim.
//  The level/bump/opacity values below are a considered first pass, not a
//  judged result.
//

import SwiftUI

struct IDCardPrinting: View {

    /// Stable per-card identity for the seeded geometry.
    var seed: String = "id-card"

    @Environment(\.passportRenderMode) private var mode

    /// The reference card all positions below are authored against.
    private let ref = IDCardMetrics.referenceSize

    private var isUV: Bool { mode.isUV }

    var body: some View {
        GeometryReader { geo in
            // Uniform scale from the 539×340 reference to the actual frame
            // (≈1 in practice, since the card is laid out at the reference).
            let s = min(geo.size.width / ref.width, geo.size.height / ref.height)

            ZStack {
                // ── Terrain — the card's one loud element after dark, as on the
                // page. gridStep 4 rather than the primitive's default 3: a
                // 539×340 rect at step 3 carries ~2.4× the page's cell count,
                // and this runs behind a card that is on screen the whole time
                // the profile is open.
                contourBand(.minor, hue: .stampTeal, uvBase: 0.42, day: 0.05,
                            uvScales: [0.55, 1.0, 1.45],
                            uvGlows: [nil, nil, (2, 0.35)],
                            width: 0.55 * s)
                contourBand(.dotted, hue: .stampTeal, uvBase: 0.42, day: 0.05,
                            uvScales: [0.55, 1.0, 1.45],
                            uvGlows: [nil, nil, (2, 0.35)],
                            width: 0.55 * s)
                contourBand(.index, hue: .stampForest, uvBase: 0.66, day: 0.08,
                            uvScales: [0.55, 1.0, 1.42],
                            uvGlows: [nil, (2, 0.4), (4, 0.7)],
                            width: 0.7 * s)

                // ── Rosette lace, cropped by the card's right and bottom edges
                // (the page crops its own at the bottom). Faint on purpose:
                // haloed and bright it reads as cloud shapes fighting the
                // contours — the lesson from the book's round 3.
                GuillocheRosette(fixedRadius: 78, rollingRadius: 13, penOffset: 36)
                    .stroke(mode.printedInk(uv: .stampViolet, uvOpacity: 0.30, day: 0.06),
                            lineWidth: 0.55 * s)
                    .frame(width: 300 * s, height: 300 * s)
                    .position(x: 470 * s, y: 250 * s)

                // ── Microprint (gold): along the bottom edge and up the right
                // edge. The page runs its bands in the gutter; a card has no
                // gutter, so they follow the two edges the content clears.
                MicroprintBand(repeatCount: 16,
                               color: mode.printedInk(uv: .stampGold, uvOpacity: 0.55, day: 0.18))
                    .position(x: ref.width / 2 * s, y: 334 * s)

                MicroprintBand(repeatCount: 10,
                               color: mode.printedInk(uv: .stampGold, uvOpacity: 0.55, day: 0.18))
                    .rotationEffect(.degrees(-90))
                    .position(x: 531 * s, y: ref.height / 2 * s)

                // ── Registration marks — sparse incidental specks, faintest
                // layer, never a pattern. keepOutBelowY clears the machine
                // strip's band (y 294–318); the primitive only takes a Y
                // threshold, so this over-excludes the bottom right too, which
                // is harmless — marks there would read as dirt on the edge.
                RegistrationMarks(seed: seed, count: 14, keepOutBelowY: 294)
                    .stroke(mode.printedInk(uv: .stampGold, uvOpacity: 0.30, day: 0.05),
                            lineWidth: 0.55 * s)

                // ── Card keyline — a single red hairline, the machine zone's
                // quiet bracket.
                IntaglioFrame(lines: [.init(inset: 8, opacity: 1.0)],
                              ink: mode.printedInk(uv: .stampRed, uvOpacity: 0.30, day: 0.06))
            }
            .frame(width: geo.size.width, height: geo.size.height)
        }
        .allowsHitTesting(false)
    }

    // MARK: - Pieces

    /// One contour band. Daylight: a single instance in uniform subtle ink.
    /// UV: one instance per bloom bucket — the same segments partitioned by the
    /// seeded bloom field, each stroked at its own intensity and glow, so
    /// fluorescence varies along the linework. The buckets' union is exactly
    /// the daylight geometry.
    ///
    /// DELIBERATELY DUPLICATED from SecurityPrinting.contourBand, for now.
    /// Extracting it before the card existed would have meant predicting what
    /// the card needs — and the last time that prediction was made (about
    /// PassportPhotoSlot) it was wrong; see DECISIONS.md 2026-07-25. This copy
    /// exists so the extraction can be made against a real second consumer
    /// rather than a forecast one. It is scheduled: extract verbatim, gated
    /// byte-identical, then parameterise separately if the card needs it.
    /// Do not "fix" this duplication ahead of that.
    @ViewBuilder
    private func contourBand(_ band: ContourField.Band, hue: Color,
                             uvBase: Double, day: Double,
                             uvScales: [Double], uvGlows: [(CGFloat, Double)?],
                             width: CGFloat) -> some View {
        if isUV {
            ForEach(0..<uvScales.count, id: \.self) { bucket in
                ContourField(seed: seed, band: band, levels: 18,
                             bumpCount: 14, gridStep: 4,
                             bloomBucket: bucket, bloomBuckets: uvScales.count)
                    .stroke(hue.opacity(min(uvBase * uvScales[bucket], 1)),
                            lineWidth: width)
                    .modifier(Halo(color: uvGlows[bucket].map { hue.opacity($0.1) } ?? .clear,
                                   radius: uvGlows[bucket]?.0 ?? 0))
            }
        } else {
            ContourField(seed: seed, band: band, levels: 18,
                         bumpCount: 14, gridStep: 4)
                .stroke(Color.ink.opacity(day), lineWidth: width)
        }
    }
}

#Preview {
    VStack(spacing: 20) {
        IDCardFace(seed: "preview") { EmptyView() }
            .frame(width: 539, height: 340)
            .environment(\.passportRenderMode, .daylight)

        IDCardFace(seed: "preview") { EmptyView() }
            .frame(width: 539, height: 340)
            .environment(\.passportRenderMode, .uv)
    }
    .padding()
    .background(Color.muted)
}
