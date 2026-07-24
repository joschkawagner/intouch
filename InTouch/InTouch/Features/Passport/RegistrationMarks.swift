//
//  RegistrationMarks.swift
//  InTouch
//
//  Scattered registration marks — the small crosses, circles and ticks that
//  dust a real passport page (UV pass). Deliberately sparse and faint:
//  incidental specks on the printed page, never a pattern — the contour field
//  carries the page. Placement uses a Halton (2,3) sequence, a power curve
//  biasing marks toward the edges and corners (where the reference clusters
//  them), and generous seeded jitter so no lattice or even spread shows.
//  Everything derives from SeededGenerator — the same seed scatters the same
//  specks forever, in both lighting states.
//
//  Marks keep out of the machine band zone (below `keepOutBelowY`, the MRZ
//  strip on the identity page) — under-text is fine at printing subtlety, but
//  marks in the machine band read as dirt. Applied on every page so the
//  geometry policy stays uniform.
//

import SwiftUI

struct RegistrationMarks: Shape {

    /// Stable page identity — same seed, same scatter, forever.
    var seed: String
    var count: Int = 12
    /// Placement inset from the page edge (inside the intaglio frame).
    var inset: CGFloat = 10
    /// No marks below this reference-space y (the MRZ machine zone).
    var keepOutBelowY: CGFloat = 292

    func path(in rect: CGRect) -> Path {
        var rng = SeededGenerator(seed: seed + "/marks")
        var path = Path()
        let placement = rect.insetBy(dx: inset, dy: inset)
        guard placement.width > 0, placement.height > 0 else { return path }

        var placed = 0
        var i = 1
        while placed < count && i <= count * 8 {
            defer { i += 1 }
            let bx = Self.edgeBias(Self.halton(i, base: 2))
            let by = Self.edgeBias(Self.halton(i, base: 3))
            let x = placement.minX + bx * placement.width + CGFloat(rng.next(in: -6...6))
            let y = placement.minY + by * placement.height + CGFloat(rng.next(in: -6...6))
            let p = CGPoint(x: x, y: y)
            guard placement.contains(p), y < rect.minY + keepOutBelowY else { continue }
            placed += 1

            let kind = rng.next(in: 0...1)
            if kind < 0.72 {
                // A "+" cross; the rare oversized one, like the reference's
                // corner registration crosses.
                let arm = CGFloat(rng.next(in: 0...1) < 0.08
                    ? rng.next(in: 4.0...5.5)
                    : rng.next(in: 2.2...3.2))
                path.move(to: CGPoint(x: p.x - arm, y: p.y))
                path.addLine(to: CGPoint(x: p.x + arm, y: p.y))
                path.move(to: CGPoint(x: p.x, y: p.y - arm))
                path.addLine(to: CGPoint(x: p.x, y: p.y + arm))
            } else if kind < 0.90 {
                let r = CGFloat(rng.next(in: 1.2...1.8))
                path.addEllipse(in: CGRect(x: p.x - r, y: p.y - r,
                                           width: 2 * r, height: 2 * r))
            } else {
                // A 45° tick — sparse accents.
                let half: CGFloat = 1.5
                path.move(to: CGPoint(x: p.x - half, y: p.y - half))
                path.addLine(to: CGPoint(x: p.x + half, y: p.y + half))
            }
        }
        return path
    }

    /// Halton low-discrepancy sequence — even coverage with no rejection loop.
    private static func halton(_ index: Int, base: Int) -> CGFloat {
        var result: CGFloat = 0
        var fraction: CGFloat = 1
        var i = index
        while i > 0 {
            fraction /= CGFloat(base)
            result += fraction * CGFloat(i % base)
            i /= base
        }
        return result
    }

    /// Pushes a 0…1 position toward the edges (exponent < 1 steepens the
    /// extremes), so marks cluster near borders and corners, sparser mid-page.
    private static func edgeBias(_ t: CGFloat) -> CGFloat {
        let centred = 2 * t - 1
        let biased = (centred < 0 ? -1 : 1) * pow(abs(centred), 0.55)
        return (biased + 1) / 2
    }
}

#Preview {
    ZStack {
        Color.paper
        RegistrationMarks(seed: "preview")
            .stroke(Color.ink.opacity(0.5), lineWidth: 0.6)
    }
    .frame(width: 232, height: 330)
}
