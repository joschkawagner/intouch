//
//  StampRing.swift
//  InTouch
//
//  The outline of a stamp.
//
//  DESIGN.md: "deliberately slightly broken/uneven like real ink". A perfect
//  circle reads as a UI element; a broken one reads as something pressed onto
//  paper. So the ring is drawn as a run of arc segments with seeded gaps and a
//  little radius wobble, rather than as one continuous circle.
//
//  Every imperfection comes from `seed`, so a given stamp's ring is identical
//  on every render, every launch, every device.
//

import SwiftUI

struct StampRing: Shape {

    /// Stable seed — pass the stamp's id.
    let seed: String

    /// Distance from the edge of the available rect.
    var inset: CGFloat = 0

    func path(in rect: CGRect) -> Path {
        var rng = SeededGenerator(seed: seed)
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let baseRadius = min(rect.width, rect.height) / 2 - inset
        guard baseRadius > 0 else { return Path() }

        var path = Path()
        var angle = rng.next(in: 0...360)   // random start, so gaps aren't all at 3 o'clock
        let finish = angle + 360

        while angle < finish {
            let sweep = rng.next(in: 26...72)
            let segmentEnd = min(angle + sweep, finish)
            let radius = baseRadius * rng.next(in: 0.985...1.015)

            // addArc draws a connecting line from the current point, so move first.
            let startRadians = angle * .pi / 180
            path.move(to: CGPoint(
                x: center.x + radius * cos(startRadians),
                y: center.y + radius * sin(startRadians)
            ))
            path.addArc(
                center: center,
                radius: radius,
                startAngle: .degrees(angle),
                endAngle: .degrees(segmentEnd),
                clockwise: false
            )

            // Most joins are hairline; roughly a third are a visible skip in the ink.
            let gap = rng.next(in: 0...1) < 0.35
                ? rng.next(in: 2...6)
                : rng.next(in: 0...0.5)
            angle = segmentEnd + gap
        }

        return path
    }
}

#Preview {
    HStack(spacing: 20) {
        ForEach(["zurich", "berlin", "lisbon"], id: \.self) { seed in
            StampRing(seed: seed, inset: 6)
                .stroke(Color.ink, lineWidth: 2)
                .frame(width: 100, height: 100)
        }
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .paperBackground()
}
