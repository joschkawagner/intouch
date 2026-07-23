//
//  IntaglioFrame.swift
//  InTouch
//
//  The intaglio frame — the nested keyline border pressed around a passport
//  page. The design insets a stack of hairline rectangles 3pt apart in fading
//  ink (two lines on a normal page, three on the colophon — the heaviest page).
//
//  Each line is one `strokeBorder` rectangle so the stroke sits fully inside the
//  page; the caller supplies the reference-space insets and their opacities.
//

import SwiftUI

struct IntaglioFrame: View {

    /// One keyline: how far it insets from the page edge, and its ink opacity.
    struct Line {
        var inset: CGFloat
        var opacity: Double
    }

    var lines: [Line]
    /// The ink the whole frame is struck in (daylight ink, or a UV glow later).
    var ink: Color

    var body: some View {
        ZStack {
            ForEach(Array(lines.enumerated()), id: \.offset) { _, line in
                Rectangle()
                    .strokeBorder(ink.opacity(line.opacity), lineWidth: 1)
                    .padding(line.inset)
            }
        }
    }
}

#Preview {
    ZStack {
        Color.paper
        IntaglioFrame(
            lines: [.init(inset: 8, opacity: 0.5), .init(inset: 11, opacity: 0.35)],
            ink: .ink
        )
    }
    .frame(width: 232, height: 330)
}
