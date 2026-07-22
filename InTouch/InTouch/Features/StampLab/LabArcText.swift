//
//  LabArcText.swift
//  InTouch
//
//  ⚠️ TEMPORARY — StampLab design lab. Safe to delete with the folder.
//
//  Text curved along a circle, at the TOP or the BOTTOM edge. The shipping
//  Core/DesignSystem/ArcText only does the top, and it's used by the real
//  StampView, so rather than widen it the lab keeps its own copy that also arcs
//  the country name upright along the bottom.
//
//  Alignment (this was drifting before): each glyph is laid out at the ZStack's
//  centre, pushed out by `radius` with `.offset`, then swung into place with
//  `.rotationEffect`. The trick — the same one the shipping ArcText relies on — is
//  that `.offset` moves what's DRAWN but not the view's layout frame, and
//  `.rotationEffect` pivots around that unmoved frame's centre. So every glyph
//  pivots around ONE common centre at the same radius, which keeps the baseline
//  even and the spacing consistent. (Positioning each glyph by its own frame centre,
//  as before, drifted because a glyph's frame centre isn't its visual centre.)
//
//  Per-glyph angle = arc-length-to-its-centre ÷ radius, so spacing follows the real
//  measured advance widths. Top text fans into a ∩; bottom into a ∪; both read
//  left-to-right, upright.
//

import SwiftUI
import UIKit

struct LabArcText: View {

    enum Edge { case top, bottom }

    let text: String
    /// Centre-of-circle to centre-of-glyph.
    let radius: CGFloat
    var edge: Edge = .top
    var uiFont: UIFont = Typography.stampCityUIFont
    var tracking: CGFloat = Typography.stampTracking

    private var characters: [Character] { Array(text) }

    /// Advance width of each character, including its share of letterspacing.
    private var widths: [CGFloat] {
        characters.map { character in
            (String(character) as NSString)
                .size(withAttributes: [.font: uiFont]).width + tracking
        }
    }

    var body: some View {
        let widths = self.widths
        let totalAngle = widths.reduce(0, +) / radius        // radians spanned

        ZStack {
            ForEach(Array(characters.enumerated()), id: \.offset) { index, character in
                let preceding = widths[..<index].reduce(0, +)
                let angle = (preceding + widths[index] / 2) / radius - totalAngle / 2

                Text(String(character))
                    .font(Font(uiFont))
                    .offset(y: edge == .top ? -radius : radius)
                    .rotationEffect(.radians(edge == .top ? angle : -angle))
            }
        }
        .frame(width: radius * 2, height: radius * 2)
    }
}

#Preview {
    ZStack {
        LabArcText(text: "SAN FRANCISCO", radius: 76, edge: .top)
        LabArcText(text: "CALIFORNIA", radius: 76, edge: .bottom,
                   uiFont: Typography.stampMarkUIFont)
    }
    .foregroundStyle(Color.ink)
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .paperBackground()
}
