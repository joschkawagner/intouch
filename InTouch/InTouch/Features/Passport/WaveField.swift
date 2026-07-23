//
//  WaveField.swift
//  InTouch
//
//  The hairline wave field — the faint repeating guilloché ripple printed across
//  a passport page beneath the type. The design tiles one small cubic wave
//  (34×12 pt: `M0,6 C8,0 17,12 34,6`) across the whole page in a hairline ink.
//
//  Built as a Shape so the whole field is one stroked path (cheap), and it fills
//  whatever rect it is given — in practice the 232×330 reference page.
//

import SwiftUI

struct WaveField: Shape {

    /// One wave tile's footprint. The cubic below is expressed against these.
    var tile = CGSize(width: 34, height: 12)

    func path(in rect: CGRect) -> Path {
        var path = Path()
        let w = tile.width, h = tile.height
        let mid = h / 2

        var y = rect.minY
        while y < rect.maxY {
            var x = rect.minX
            while x < rect.maxX {
                // M0,6  C8,0 17,12 34,6 — a single S-less crest-then-trough wave.
                path.move(to: CGPoint(x: x, y: y + mid))
                path.addCurve(
                    to: CGPoint(x: x + w, y: y + mid),
                    control1: CGPoint(x: x + w * 8 / 34, y: y),
                    control2: CGPoint(x: x + w * 17 / 34, y: y + h)
                )
                x += w
            }
            y += h
        }
        return path
    }
}

#Preview {
    ZStack {
        Color.paper
        WaveField()
            .stroke(Color.ink.opacity(0.25), lineWidth: 0.6)
    }
    .frame(width: 232, height: 330)
}
