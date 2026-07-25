//
//  GuillocheRosette.swift
//  InTouch
//
//  A guilloché rosette — the fine looping lace printed on banknotes and passport
//  pages to make them hard to forge. The design (Passport Cover Directions)
//  specifies "parametric epitrochoid curves, cropped by the page edge"; this is
//  that curve computed directly rather than a baked SVG path, so it stays crisp
//  at any scale and is tunable.
//
//  An epitrochoid is the trace of a point offset `d` from the centre of a small
//  circle (radius `r`) rolling around the outside of a fixed circle (radius `R`):
//
//      x(t) = (R + r)·cos t − d·cos(((R + r)/r)·t)
//      y(t) = (R + r)·sin t − d·sin(((R + r)/r)·t)
//
//  The number of outer lobes is R/r; `d` sets how deep the scallops cut (and,
//  past `r`, opens interior loops — the crisscross that reads as real guilloché).
//  The curve is drawn to fill its rect; place it partly off-page for the design's
//  cropped-by-the-edge rosettes.
//

import SwiftUI

struct GuillocheRosette: Shape {

    /// Fixed-circle radius (relative units — the curve is scaled to its rect).
    var fixedRadius: CGFloat
    /// Rolling-circle radius. `fixedRadius / rollingRadius` is the lobe count.
    var rollingRadius: CGFloat
    /// Pen offset from the rolling centre. Larger cuts deeper; past `rollingRadius`
    /// it opens interior loops.
    var penOffset: CGFloat
    /// Samples along the curve. Higher is smoother; 720 is plenty for a page rosette.
    var samples: Int = 720

    func path(in rect: CGRect) -> Path {
        let R = fixedRadius, r = max(rollingRadius, 0.0001), d = penOffset
        let k = (R + r) / r

        // The curve closes after the rolling circle has made `r / gcd(R, r)`
        // full turns; sample exactly that span so the loop meets its own start.
        let turns = r / CGFloat(Self.gcd(Int(R.rounded()), Int(r.rounded())))
        let total = 2 * .pi * max(turns, 1)

        // Raw extent of the curve, so we can scale it to fill the rect.
        let extent = (R + r) + d
        let scale = min(rect.width, rect.height) / 2 / max(extent, 0.0001)
        let c = CGPoint(x: rect.midX, y: rect.midY)

        var path = Path()
        for i in 0...samples {
            let t = total * CGFloat(i) / CGFloat(samples)
            let x = (R + r) * cos(t) - d * cos(k * t)
            let y = (R + r) * sin(t) - d * sin(k * t)
            let pt = CGPoint(x: c.x + x * scale, y: c.y + y * scale)
            if i == 0 { path.move(to: pt) } else { path.addLine(to: pt) }
        }
        path.closeSubpath()
        return path
    }

    private static func gcd(_ a: Int, _ b: Int) -> Int {
        var a = abs(a), b = abs(b)
        while b != 0 { (a, b) = (b, a % b) }
        return max(a, 1)
    }
}

#Preview {
    ZStack {
        Color.paper
        GuillocheRosette(fixedRadius: 78, rollingRadius: 13, penOffset: 36)
            .stroke(Color.ink.opacity(0.5), lineWidth: 0.6)
            .frame(width: 200, height: 200)
    }
    .frame(width: 232, height: 330)
}
