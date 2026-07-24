//
//  PassportCoverField.swift
//  InTouch
//
//  The oxblood cover material, shared by the front cover and the back cover.
//  The design gives both the same treatment (§ 2e "same material, far quieter"):
//  the `ink` field, a diagonal light-catch, soft corner vignettes, a whisper
//  of grain so it reads as an aged document surface — and the cover's own
//  security printing: a contour field with scattered registration marks.
//
//  ONE OBJECT, TWO LIGHTING STATES, on the cover too. By day the printing is
//  tone-on-tone — pale lines at whisper opacity, the way the real Swiss cover
//  embosses its contours red-on-red. After dark the cover pigment sinks
//  toward the night ground (oxblood itself doesn't fluoresce) but the
//  PRINTING blazes red with gold specks — the UV reference's covers carry
//  exactly this. (Supersedes the P7b "covers sink, nothing fluoresces"
//  behaviour, which was an error against the reference — see DECISIONS.md
//  2026-07-25.)
//

import SwiftUI

struct PassportCoverField: View {

    /// Stable identity for this cover's printing geometry — front and back
    /// covers print different terrain.
    var seed: String = "cover"

    @Environment(\.passportRenderMode) private var mode

    var body: some View {
        ZStack {
            Color.ink

            // Diagonal light-catch: a highlight top-left, a deepening bottom-right.
            LinearGradient(
                stops: [
                    .init(color: Color.paper.opacity(0.05), location: 0),
                    .init(color: .clear, location: 0.38),
                    .init(color: .clear, location: 0.62),
                    .init(color: Color.text.opacity(0.16), location: 1),
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )

            CornerVignettes(color: Color.text.opacity(0.14), reach: 0.24)

            CoverGrain()

            // After dark the oxblood pigment doesn't fluoresce — the field
            // sinks toward the night ground. (A lighting wash; the printing
            // above it is the UV-reactive layer and stays full strength.)
            if mode.isUV {
                Color.uvGround.opacity(0.6)
            }

            CoverPrinting(seed: seed)
        }
        .allowsHitTesting(false)
    }
}

/// The cover's security printing — the book's contour/mark vocabulary, tuned
/// for the dark oxblood ground. Identical geometry in both modes: pale
/// embossed tone-on-tone lines by day; after dark the contours fluoresce
/// red (index lines blooming through the seeded intensity buckets, like the
/// interior pages) with gold registration specks.
private struct CoverPrinting: View {

    var seed: String

    @Environment(\.passportRenderMode) private var mode
    private var isUV: Bool { mode.isUV }

    var body: some View {
        ZStack {
            // Faint base: solid minors + dotted interleave.
            ContourField(seed: seed, band: .minor, levels: 12, bumpCount: 10)
                .stroke(isUV ? Color.stampRed.opacity(0.34) : Color.paper.opacity(0.05),
                        lineWidth: 0.55)
            ContourField(seed: seed, band: .dotted, levels: 12, bumpCount: 10)
                .stroke(isUV ? Color.stampRed.opacity(0.34) : Color.paper.opacity(0.05),
                        lineWidth: 0.55)

            // Index lines carry the blaze, blooming unevenly under UV;
            // daylight draws the buckets' union in one uniform whisper.
            if isUV {
                ForEach(0..<3, id: \.self) { bucket in
                    ContourField(seed: seed, band: .index, levels: 12,
                                 bumpCount: 10, bloomBucket: bucket, bloomBuckets: 3)
                        .stroke(Color.stampRed.opacity([0.38, 0.62, 0.88][bucket]),
                                lineWidth: 0.7)
                        .shadow(color: bucket == 2 ? Color.stampRed.opacity(0.7) : .clear,
                                radius: bucket == 2 ? 4 : 0)
                        .shadow(color: bucket == 1 ? Color.stampRed.opacity(0.4) : .clear,
                                radius: bucket == 1 ? 2 : 0)
                }
            } else {
                ContourField(seed: seed, band: .index, levels: 12, bumpCount: 10)
                    .stroke(Color.paper.opacity(0.07), lineWidth: 0.7)
            }

            // Sparse gold specks, as on the interior pages.
            RegistrationMarks(seed: seed, count: 10)
                .stroke(isUV ? Color.stampGold.opacity(0.30) : Color.paper.opacity(0.05),
                        lineWidth: 0.55)
        }
    }
}

/// A whisper of procedural grain over the cover, so the oxblood field reads as an
/// aged surface. Deterministic (a fixed PRNG seed) so it never shimmers between
/// frames. Carried over from the first-pass cover.
private struct CoverGrain: View {
    var body: some View {
        Canvas { context, size in
            let fleck = GraphicsContext.Shading.color(Color.paper.opacity(0.03))
            var seed: UInt64 = 0x9E3779B97F4A7C15
            func next() -> Double {
                seed = seed &* 6364136223846793005 &+ 1442695040888963407
                return Double(seed >> 11) / Double(1 << 53)
            }
            for _ in 0..<260 {
                let x = next() * size.width
                let y = next() * size.height
                let r = 0.4 + next() * 0.8
                context.fill(
                    Path(ellipseIn: CGRect(x: x, y: y, width: r, height: r)),
                    with: fleck
                )
            }
        }
    }
}

#Preview {
    HStack(spacing: 16) {
        PassportCoverField()
            .frame(width: 232, height: 330)
            .clipShape(RoundedRectangle(cornerRadius: 8))
            .environment(\.passportRenderMode, .daylight)
        PassportCoverField()
            .frame(width: 232, height: 330)
            .clipShape(RoundedRectangle(cornerRadius: 8))
            .environment(\.passportRenderMode, .uv)
    }
    .padding()
    .background(Color.muted)
}
