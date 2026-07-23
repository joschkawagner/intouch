//
//  PassportCoverField.swift
//  InTouch
//
//  The oxblood cover material, shared by the front cover and the back cover.
//  The design gives both the same treatment (§ 2e "same material, far quieter"):
//  the `ink` field, a diagonal light-catch, soft corner vignettes, and a whisper
//  of grain so it reads as an aged document surface rather than a flat fill.
//  The front cover lays its wordmark over this; the back cover is this alone.
//

import SwiftUI

struct PassportCoverField: View {

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

            // After dark the oxblood pigment doesn't fluoresce — it sinks toward
            // the night ground rather than staying a lit red panel.
            if mode.isUV {
                Color.uvGround.opacity(0.6)
            }
        }
        .allowsHitTesting(false)
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
    PassportCoverField()
        .frame(width: 232, height: 330)
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .padding()
        .background(Color.muted)
}
