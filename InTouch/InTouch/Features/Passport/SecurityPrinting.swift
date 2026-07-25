//
//  SecurityPrinting.swift
//  InTouch
//
//  The security-printing layer that sits *beneath* a passport page's identity
//  content — the contour terrain, guilloché rosettes, microprint bands,
//  scattered registration marks and the page keyline that make the page read
//  as a printed document rather than a card. Composed from the parametric
//  primitives (ContourField, GuillocheRosette, MicroprintBand,
//  RegistrationMarks, IntaglioFrame) in the 232×330 reference space (see
//  PassportPage), sharing one coordinate system with the content above.
//
//  ONE OBJECT, TWO LIGHTING STATES. Every element exists identically in both
//  modes; only the lighting differs. Daylight prints the whole layer in the
//  one subtle `ink` at whisper opacities — clearly beneath the content
//  hierarchy, the standing P2 rule. Under UV the same geometry fluoresces in
//  the stamp register, hue-zoned like the reference: teal/forest terrain,
//  gold microprint and marks, violet/cobalt rosette lace, a red machine
//  keyline. Never fork the geometry between modes.
//
//  THE CONTOURS CARRY THE PAGE. The terrain is the one loud element after
//  dark — its index lines bloom hot in uneven seeded stretches (real UV ink
//  pools and fades; flat uniform strokes read as vector art — see
//  ContourField's bloom buckets). Everything else — rosettes, marks,
//  microprint, the single hairline keyline — is subordinate texture pinned
//  well beneath the terrain.
//
//  Two levels: `.standard` (identity, city, collage) and `.heavy` (the
//  colophon — second rosette, extra bands, denser terrain).
//

import SwiftUI

struct SecurityPrinting: View {

    enum Level { case standard, heavy }

    var level: Level = .standard
    /// Stable per-page identity for the seeded geometry (contours, marks).
    /// The same seed prints the same page forever, in both modes.
    var seed: String = "passport"

    @Environment(\.passportRenderMode) private var mode

    /// The reference page all positions below are authored against.
    private let ref = PassportMetrics.referenceSize

    private var isHeavy: Bool { level == .heavy }
    private var isUV: Bool { mode.isUV }

    /// Daylight prints every element in the one subtle ink; UV gives each its
    /// zone hue and its own quiet (or blooming) intensity. The policy itself
    /// lives on `PassportRenderMode` (Core/SecurityPrinting/PrintedInk.swift)
    /// so this composition and the ID card's cannot drift apart.
    private func printedInk(uv uvHue: Color, uvOpacity: Double, day: Double) -> Color {
        mode.printedInk(uv: uvHue, uvOpacity: uvOpacity, day: day)
    }

    var body: some View {
        GeometryReader { geo in
            // Uniform scale from the 232×330 reference to the actual page frame
            // (≈1 in practice, since pages are laid out at the reference size).
            let s = min(geo.size.width / ref.width, geo.size.height / ref.height)
            let levels = isHeavy ? 24 : 18
            let bumps = isHeavy ? 18 : 14

            ZStack {
                // ── Terrain — the page's one loud element. Solid minors and a
                // dotted interleave as the base; index lines carry the blaze,
                // blooming unevenly through the seeded intensity buckets.
                contourBand(.minor, hue: .stampTeal, uvBase: 0.42, day: 0.05,
                            uvScales: [0.55, 1.0, 1.45],
                            uvGlows: [nil, nil, (2, 0.35)],
                            width: 0.55 * s, levels: levels, bumps: bumps)
                contourBand(.dotted, hue: .stampTeal, uvBase: 0.42, day: 0.05,
                            uvScales: [0.55, 1.0, 1.45],
                            uvGlows: [nil, nil, (2, 0.35)],
                            width: 0.55 * s, levels: levels, bumps: bumps)
                contourBand(.index, hue: .stampForest, uvBase: 0.66, day: 0.08,
                            uvScales: [0.55, 1.0, 1.42],
                            uvGlows: [nil, (2, 0.4), (4, 0.7)],
                            width: 0.7 * s, levels: levels, bumps: bumps)

                // ── Rosette lace — guilloché beneath the terrain, faint on
                // purpose (haloed and bright it reads as cloud shapes that
                // fight the contours). Heavy pages add a cobalt second.
                GuillocheRosette(fixedRadius: 78, rollingRadius: 13, penOffset: 36)
                    .stroke(printedInk(uv: .stampViolet, uvOpacity: 0.30, day: 0.06),
                            lineWidth: 0.55 * s)
                    .frame(width: 254 * s, height: 254 * s)
                    .position(x: 190 * s, y: 270 * s)

                if isHeavy {
                    GuillocheRosette(fixedRadius: 70, rollingRadius: 14, penOffset: 46)
                        .stroke(printedInk(uv: .stampCobalt, uvOpacity: 0.26, day: 0.05),
                                lineWidth: 0.55 * s)
                        .frame(width: 230 * s, height: 230 * s)
                        .position(x: 40 * s, y: 55 * s)
                }

                // ── Microprint (gold): vertical gutter band(s) plus a
                // horizontal row along the top edge; heavy pages mirror both.
                microprint(repeatCount: 10)
                    .rotationEffect(.degrees(-90))
                    .position(x: 7 * s, y: ref.height / 2 * s)
                microprint(repeatCount: 7)
                    .position(x: ref.width / 2 * s, y: 5 * s)

                if isHeavy {
                    microprint(repeatCount: 10)
                        .rotationEffect(.degrees(-90))
                        .position(x: 225 * s, y: ref.height / 2 * s)
                    microprint(repeatCount: 7)
                        .position(x: ref.width / 2 * s, y: 325 * s)
                }

                // ── Registration marks — sparse incidental specks, faintest
                // layer; never a pattern.
                RegistrationMarks(seed: seed, count: isHeavy ? 16 : 12)
                    .stroke(printedInk(uv: .stampGold, uvOpacity: 0.30, day: 0.05),
                            lineWidth: 0.55 * s)

                // ── Page keyline — a single red hairline, the machine zone's
                // quiet bracket (the old triple intaglio frame boxed the page
                // in and shouted over the terrain).
                IntaglioFrame(lines: [.init(inset: 8, opacity: 1.0)],
                              ink: printedInk(uv: .stampRed, uvOpacity: 0.30, day: 0.06))
            }
            .frame(width: geo.size.width, height: geo.size.height)
        }
        .allowsHitTesting(false)
    }

    // MARK: - Pieces

    /// One contour band. Daylight: a single instance in uniform subtle ink.
    /// UV: one instance per bloom bucket — the same segments partitioned by
    /// the seeded bloom field, each stroked at its own intensity and glow, so
    /// fluorescence varies along the linework. The buckets' union is exactly
    /// the daylight geometry.
    @ViewBuilder
    private func contourBand(_ band: ContourField.Band, hue: Color,
                             uvBase: Double, day: Double,
                             uvScales: [Double], uvGlows: [(CGFloat, Double)?],
                             width: CGFloat, levels: Int, bumps: Int) -> some View {
        if isUV {
            ForEach(0..<uvScales.count, id: \.self) { bucket in
                ContourField(seed: seed, band: band, levels: levels,
                             bumpCount: bumps, bloomBucket: bucket,
                             bloomBuckets: uvScales.count)
                    .stroke(hue.opacity(min(uvBase * uvScales[bucket], 1)),
                            lineWidth: width)
                    .modifier(Halo(color: uvGlows[bucket].map { hue.opacity($0.1) } ?? .clear,
                                   radius: uvGlows[bucket]?.0 ?? 0))
            }
        } else {
            ContourField(seed: seed, band: band, levels: levels, bumpCount: bumps)
                .stroke(Color.ink.opacity(day), lineWidth: width)
        }
    }

    private func microprint(repeatCount: Int) -> some View {
        MicroprintBand(repeatCount: repeatCount,
                       color: printedInk(uv: .stampGold, uvOpacity: 0.55,
                                         day: isHeavy ? 0.20 : 0.18))
    }
}

// `Halo` lived here until the ID card needed the same conditional glow; it is
// now Core/SecurityPrinting/PrintedInk.swift, unchanged in form so the
// `.modifier(Halo(...))` call site above renders through the identical wrapper.

#Preview {
    HStack(spacing: 20) {
        PassportPage(security: .standard, seed: "preview") { EmptyView() }
            .frame(width: 232, height: 330)
            .environment(\.passportRenderMode, .daylight)

        PassportPage(security: .heavy, seed: "preview") { EmptyView() }
            .frame(width: 232, height: 330)
            .environment(\.passportRenderMode, .uv)
    }
    .padding()
    .background(Color.muted)
}
