//
//  InkWear.swift
//  InTouch
//
//  ⚠️ TEMPORARY — StampLab design lab. Safe to delete with the folder.
//
//  Distress, seeded and shape-agnostic. Real hand-struck ink is never even: it
//  fades under light pressure, starves in patches, and breaks along the edges.
//
//  The trick that makes this work on ANY shape without per-shape code: distress is
//  a `.mask` laid over the finished stamp. The mask is a Canvas that starts fully
//  opaque (the stamp shows everywhere) and then punches transparent specks and
//  scratches into it — so wherever a hole lands, that bit of ink is eaten away.
//  Holes outside the ink do nothing, so one rectangular mask erodes border, text
//  and photo alike. Everything is drawn from `SeededGenerator(seed:)`, so a given
//  stamp's wear is identical on every render — it never jumps.
//
//  `strength` runs 0 (crisp) … 1 (heavily worn). Most stamps sit low so they stay
//  readable ("a stamp you can't read is a memory you can't recall"); a few are
//  pushed high on purpose to show the far end of the range.
//

import SwiftUI

extension View {
    /// Ages this view like struck ink: a seeded overall fade plus a seeded erosion
    /// mask. `shape`/`inset` let the mask break the border band a little harder,
    /// matching where the outer rule sits.
    func inkWear(seed: String, shape: StampShape, inset: CGFloat, strength: Double) -> some View {
        modifier(InkWear(seed: seed, shape: shape, inset: inset, strength: strength))
    }
}

struct InkWear: ViewModifier {
    let seed: String
    let shape: StampShape
    let inset: CGFloat
    let strength: Double

    func body(content: Content) -> some View {
        content
            // Ink on absorbent paper is never fully opaque; heavier wear = lighter strike.
            .opacity(0.92 - strength * 0.28)
            .mask { InkWearMask(seed: seed, shape: shape, inset: inset, strength: strength) }
    }
}

/// The erosion mask: opaque, with seeded bites taken out of it.
private struct InkWearMask: View {
    let seed: String
    let shape: StampShape
    let inset: CGFloat
    let strength: Double

    var body: some View {
        Canvas { context, size in
            // Opaque base — the whole stamp is kept until something erases it.
            context.fill(Path(CGRect(origin: .zero, size: size)), with: .color(.black))

            var rng = SeededGenerator(seed: seed + ".wear")
            context.blendMode = .destinationOut     // subsequent draws *remove* alpha

            // 1. Fine ink-starve speckle scattered across the face.
            let speckles = Int(50 + 320 * strength)
            for _ in 0..<speckles {
                let x = rng.next(in: 0...Double(size.width))
                let y = rng.next(in: 0...Double(size.height))
                let r = rng.next(in: 0.4...3.0) * (0.6 + strength)
                context.opacity = rng.next(in: 0.25...1.0)
                context.fill(
                    Path(ellipseIn: CGRect(x: x - r, y: y - r, width: r * 2, height: r * 2)),
                    with: .color(.black)
                )
            }

            // 2. A few soft pressure-fade patches — larger, lighter, uneven inking.
            let fades = Int(2 + 5 * strength)
            for _ in 0..<fades {
                let x = rng.next(in: 0...Double(size.width))
                let y = rng.next(in: 0...Double(size.height))
                let r = rng.next(in: 12...36) * (0.7 + strength)
                context.opacity = rng.next(in: 0.10...0.32)
                context.fill(
                    Path(ellipseIn: CGRect(x: x - r, y: y - r, width: r * 2, height: r * 2)),
                    with: .color(.black)
                )
            }

            // 3. Break the border band: a dashed stroke of "nothing" along the outer
            //    rule, so the outline reads as skipped ink rather than a clean line.
            let border = shape.path(in: CGRect(origin: .zero, size: size)
                .insetBy(dx: inset, dy: inset))
            context.opacity = 0.5 + 0.5 * strength
            let dashes: [CGFloat] = [rng.next(in: 5...10), rng.next(in: 2...5)]
            context.stroke(
                border,
                with: .color(.black),
                style: StrokeStyle(lineWidth: 2.4 + strength * 2.2, lineCap: .round,
                                   dash: dashes, dashPhase: rng.next(in: 0...12))
            )
        }
        .allowsHitTesting(false)
    }
}
