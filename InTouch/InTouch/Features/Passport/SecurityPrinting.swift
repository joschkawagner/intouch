//
//  SecurityPrinting.swift
//  InTouch
//
//  The security-printing layer that sits *beneath* a passport page's identity
//  content — the guilloché, wave field, microprint and intaglio frame that make
//  the page read as a printed document rather than a card. Composed from the
//  four primitives (GuillocheRosette, WaveField, MicroprintBand, IntaglioFrame)
//  and laid out in the 232×330 reference space (see PassportPage), so it shares
//  one coordinate system with the content drawn on top.
//
//  Two levels, from the design: `.standard` for the identity and city pages
//  (one rosette, one microprint band, a two-line frame) and `.heavy` for the
//  colophon (a second rosette, a second band, a three-line frame — the strongest
//  printing in the book).
//
//  Daylight only for now. The after-dark (UV) treatment — where the grid and
//  rosettes fluoresce — arrives with the time-of-day render mode in a later
//  phase; `ink` is the single seam that switch will pass through.
//

import SwiftUI

struct SecurityPrinting: View {

    enum Level { case standard, heavy }

    var level: Level = .standard
    /// The ink the whole layer is printed in. Daylight is `ink`; the UV phase
    /// will pass a fluorescing ink here instead.
    var ink: Color = .ink

    /// The reference page all positions below are authored against.
    private let ref = PassportMetrics.referenceSize

    private var isHeavy: Bool { level == .heavy }

    var body: some View {
        GeometryReader { geo in
            // Uniform scale from the 232×330 reference to the actual page frame
            // (≈1 in practice, since pages are laid out at the reference size).
            let s = min(geo.size.width / ref.width, geo.size.height / ref.height)

            ZStack {
                // Wave field — full bleed, faintest layer.
                WaveField()
                    .stroke(ink.opacity(isHeavy ? 0.08 : 0.07), lineWidth: 0.6 * s)

                // Primary rosette, bottom-right, cropped by the page edge.
                rosette(fixedRadius: 78, rollingRadius: 13, penOffset: 36,
                        opacity: isHeavy ? 0.09 : 0.06, s: s)
                    .frame(width: 254 * s, height: 254 * s)
                    .position(x: 190 * s, y: 270 * s)

                // Heavy pages add a second, loopier rosette top-left.
                if isHeavy {
                    rosette(fixedRadius: 70, rollingRadius: 14, penOffset: 46,
                            opacity: 0.09, s: s)
                        .frame(width: 230 * s, height: 230 * s)
                        .position(x: 40 * s, y: 55 * s)
                }

                // Microprint band up the left gutter (and the right on heavy pages).
                MicroprintBand(color: ink.opacity(isHeavy ? 0.20 : 0.18))
                    .rotationEffect(.degrees(-90))
                    .position(x: 7 * s, y: ref.height / 2 * s)

                if isHeavy {
                    MicroprintBand(color: ink.opacity(0.20))
                        .rotationEffect(.degrees(-90))
                        .position(x: 225 * s, y: ref.height / 2 * s)
                }

                // Intaglio frame — the topmost, most defined layer.
                IntaglioFrame(lines: frameLines, ink: ink)
            }
            .frame(width: geo.size.width, height: geo.size.height)
        }
        .allowsHitTesting(false)
    }

    private func rosette(fixedRadius: CGFloat, rollingRadius: CGFloat,
                         penOffset: CGFloat, opacity: Double, s: CGFloat) -> some View {
        GuillocheRosette(fixedRadius: fixedRadius, rollingRadius: rollingRadius,
                         penOffset: penOffset)
            .stroke(ink.opacity(opacity), lineWidth: 0.7 * s)
    }

    private var frameLines: [IntaglioFrame.Line] {
        isHeavy
            ? [.init(inset: 8, opacity: 0.11),
               .init(inset: 11, opacity: 0.09),
               .init(inset: 14, opacity: 0.07)]
            : [.init(inset: 8, opacity: 0.10),
               .init(inset: 11, opacity: 0.07)]
    }
}

#Preview {
    HStack(spacing: 20) {
        PassportPage {
            SecurityPrinting(level: .standard)
        }
        .frame(width: 232, height: 330)

        PassportPage {
            SecurityPrinting(level: .heavy)
        }
        .frame(width: 232, height: 330)
    }
    .padding()
    .background(Color.muted)
}
