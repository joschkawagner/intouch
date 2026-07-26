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
//  ✅ THE TERRAIN DENSITY IS JUDGED. An earlier version of this header said the
//  level/bump/opacity values below were "a considered first pass, not a judged
//  result". That was ALREADY FALSE when it stood here: 78b3ddc ("ID card:
//  terrain density scaled to the card's area (judged on screen)") modified this
//  very file after the values were compared on screen in both modes in the
//  short-lived ID-card lab, and DECISIONS.md 2026-07-25 records the same from
//  the other side — "the terrain density, which WAS judged on screen in both
//  modes before the route was removed". The first-pass numbers carried the
//  page's 14 bumps onto a card of 2.4x the area and read far too sparse.
//
//  ⚠️ BUT DENSITY IS CONTAINER-DEPENDENT, and this is the live caveat. The
//  primitives are authored in ABSOLUTE POINTS (MicroprintBand at 4pt) while the
//  card scales its 539x340 reference to fit. So the card's LAYOUT is
//  scale-invariant and layout judgements survive a presentation change, while
//  PRINTING DENSITY RELATIVE TO THE CARD IS NOT and density judgements do not.
//  Everything here was judged at the `.sheet` container size; moving to
//  fullScreenCover changes the scale factor and therefore the printed density.
//  Re-look after that lands — do not carry these numbers across on the strength
//  of the layout having been unaffected.
//

import SwiftUI

struct IDCardPrinting: View {

    /// Stable per-card identity for the seeded geometry.
    var seed: String = "id-card"

    @Environment(\.passportRenderMode) private var mode

    /// The reference card all positions below are authored against.
    private let ref = IDCardMetrics.referenceSize

    private var isUV: Bool { mode.isUV }

    // MARK: - Terrain density (judged in the lab, not carried from the page)
    //
    // The first pass reused the page's numbers unchanged (18 levels, 14 bumps)
    // and dropped gridStep to 4 to "control cost". Seen on screen it read far
    // too sparse in both modes — big lazy loops where the book has dense
    // topography — because two different things had been conflated:
    //
    //   gridStep  — line RESOLUTION (and most of the cost)
    //   bumpCount — how much TERRAIN there is (feature density)
    //
    // The card is 539×340 = 183,260pt² against the page's 232×330 = 76,560pt²,
    // i.e. 2.39× the area. Keeping the page's bump count spreads the same
    // features 2.4× thinner; dropping the resolution on top made it coarser
    // still. So: bumps scale WITH AREA, and gridStep returns to the
    // primitive's default so the line quality matches the book's.
    //
    // Cost, actually computed: page ≈ 8,470 cells/band at step 3; card ≈ 20,340
    // (2.4×). Affordable here in a way it would not be in the book — the card
    // is ONE object on ONE screen, where PassportBookView eagerly builds nine
    // spreads at once.
    private static let gridStep: CGFloat = 3
    private static let levels = 20
    private static let bumps = 32

    var body: some View {
        GeometryReader { geo in
            // Uniform scale from the 539×340 reference to the actual frame
            // (≈1 in practice, since the card is laid out at the reference).
            let s = min(geo.size.width / ref.width, geo.size.height / ref.height)

            ZStack {
                // ── Terrain — the card's one loud element after dark, as on
                // the page. Density JUDGED in the lab (see the band function):
                // the first pass carried the page's numbers unchanged and read
                // far too sparse, because the card is 2.4× the page's area.
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
                ContourField(seed: seed, band: band, levels: Self.levels,
                             bumpCount: Self.bumps, gridStep: Self.gridStep,
                             bloomBucket: bucket, bloomBuckets: uvScales.count)
                    .stroke(hue.opacity(min(uvBase * uvScales[bucket], 1)),
                            lineWidth: width)
                    .modifier(Halo(color: uvGlows[bucket].map { hue.opacity($0.1) } ?? .clear,
                                   radius: uvGlows[bucket]?.0 ?? 0))
            }
        } else {
            ContourField(seed: seed, band: band, levels: Self.levels,
                         bumpCount: Self.bumps, gridStep: Self.gridStep)
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
