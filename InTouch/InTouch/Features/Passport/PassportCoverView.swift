//
//  PassportCoverView.swift
//  InTouch
//
//  The closed passport cover, at rest, in portrait — Phase-3 (P3) first pass.
//
//  DESIGN.md § The passport cover: one InTouch cover tinted into the colour
//  *family* of the user's home-country passport (here the red family — Color.ink,
//  "Red Inferno"), that wears visibly with use over time. This is the static
//  closed cover only; rotate-to-open and the two-page spreads are later sub-phases.
//
//  The language is Swiss / International Typographic Style: a strict grid, content
//  flush-left to one margin, bottom-weighted asymmetry, generous whitespace, type
//  and colour carrying the whole thing. No crest, no cross, no guilloché, no
//  wordmark hero — it speaks as a document through grid + type + colour.
//

import SwiftUI

struct PassportCoverView: View {

    /// The single flush-left margin the whole grid answers to.
    private let margin: CGFloat = 30

    /// Inset of the thin keyline frame from the safe-area edge.
    private let frameInset: CGFloat = 18

    var body: some View {
        ZStack {
            Color.ink
                .ignoresSafeArea()

            CoverWear()
                .ignoresSafeArea()

            // A thin document keyline — structure, not ornament.
            Rectangle()
                .strokeBorder(Color.paper.opacity(0.22), lineWidth: 1)
                .padding(frameInset)
                .ignoresSafeArea()

            // The type grid: flush-left, weighted low.
            VStack(alignment: .leading, spacing: 0) {
                Text(Typography.chrome("type  p · int"))
                    .font(Typography.timestamp)
                    .tracking(Typography.stampTracking)
                    .foregroundStyle(Color.paper.opacity(0.6))

                Spacer(minLength: 0)

                Rectangle()
                    .fill(Color.paper.opacity(0.28))
                    .frame(width: 44, height: 1)
                    .padding(.bottom, 14)

                Text(Typography.chrome("pass"))
                    .font(Typography.masthead)
                    .foregroundStyle(Color.paper)

                Text(Typography.chrome("you had to be there"))
                    .font(Typography.label)
                    .tracking(1.5)
                    .foregroundStyle(Color.paper.opacity(0.7))
                    .padding(.top, 6)

                Text(Typography.chrome("int · 0001"))
                    .font(Typography.timestamp)
                    .tracking(Typography.stampTracking)
                    .foregroundStyle(Color.paper.opacity(0.5))
                    .padding(.top, 20)
            }
            .padding(margin)
        }
    }
}

/// A very light "worn with use" pass over the cover: a faint diagonal light-catch
/// and a whisper of grain, so the field reads as an aged document surface rather
/// than a flat fill. Kept deliberately subtle — wear deepens in a later pass.
private struct CoverWear: View {

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Color.paper.opacity(0.05), .clear, Color.paper.opacity(0.02)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )

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
        .allowsHitTesting(false)
    }
}

#Preview {
    PassportCoverView()
}
