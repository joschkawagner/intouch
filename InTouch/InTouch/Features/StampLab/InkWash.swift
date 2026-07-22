//
//  InkWash.swift
//  InTouch
//
//  ⚠️ TEMPORARY — StampLab design lab. Safe to delete with the folder.
//
//  The interior ink wash — the realism fix. A real rubber stamp presses ink across
//  its WHOLE inside, unevenly: heavier in patches, lighter in others, as the hand
//  bears down unevenly. Without it, a stamp's middle is bright white paper with a
//  mark floating in it, which reads as clip-art, not ink.
//
//  So: a faint base tint over the whole interior, plus a handful of soft, seeded
//  blobs blurred into an uneven blotch. Kept subtle — it should read as "inked
//  paper", not a fill. Seeded from the stamp id, so the blotch is varied per stamp
//  but stable across renders. Sits UNDER the landmark and text; the wear mask then
//  goes over everything.
//

import SwiftUI

struct InkWash: View {
    let seed: String
    let shape: StampShape
    let ink: Color
    /// Inset from the outer edge — the wash fills nearly the whole face.
    var inset: CGFloat = 7

    var body: some View {
        let interior = StampOutline(shape: shape, inset: inset)
        ZStack {
            interior.fill(ink.opacity(0.05))                 // faint base tint
            Canvas { context, size in
                var rng = SeededGenerator(seed: seed + ".wash")
                let minSide = Double(min(size.width, size.height))
                for _ in 0..<16 {
                    let cx = rng.next(in: 0...Double(size.width))
                    let cy = rng.next(in: 0...Double(size.height))
                    let radius = rng.next(in: 0.14...0.42) * minSide
                    let opacity = rng.next(in: 0.02...0.07)
                    context.fill(
                        Path(ellipseIn: CGRect(x: cx - radius, y: cy - radius,
                                               width: radius * 2, height: radius * 2)),
                        with: .color(ink.opacity(opacity))
                    )
                }
            }
            .blur(radius: 5)                                 // soften the blobs into a wash
            .clipShape(interior)                             // keep it inside the stamp
        }
        .allowsHitTesting(false)
    }
}
