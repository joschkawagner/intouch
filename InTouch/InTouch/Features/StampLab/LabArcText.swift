//
//  LabArcText.swift
//  InTouch
//
//  ⚠️ TEMPORARY — StampLab design lab. Safe to delete with the folder.
//
//  Text curved along a circle, at the TOP or the BOTTOM edge. The shipping
//  Core/DesignSystem/ArcText only does the top, and it's used by the real
//  StampView, so rather than widen it (and risk the shipping stamp) the lab keeps
//  its own copy that also arcs the country name along the bottom — the way real
//  round stamps read (SYDNEY over the top, AUSTRALIA under the bottom).
//
//  SwiftUI has no curved text, so each glyph is placed by hand. The maths mirrors
//  ArcText but is written with explicit trig and `.position` so the bottom case is
//  unambiguous:
//    • measure each glyph in the real UIFont (a SwiftUI Font can't be measured),
//    • convert its advance to an angle: angle = width / radius,
//    • place its centre on the circle and rotate it to sit on the curve.
//  Top text fans into a ∩ (frown); bottom text fans into a ∪ (smile) so both read
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
        let totalAngle = widths.reduce(0, +) / radius     // radians spanned
        let center = radius                               // in a diameter×diameter box

        ZStack {
            ForEach(Array(characters.enumerated()), id: \.offset) { index, character in
                let preceding = widths[..<index].reduce(0, +)
                let phi = (preceding + widths[index] / 2) / radius - totalAngle / 2

                Text(String(character))
                    .font(Font(uiFont))
                    .rotationEffect(.radians(edge == .top ? phi : -phi))
                    .position(
                        x: center + radius * sin(phi),
                        y: edge == .top ? center - radius * cos(phi)
                                        : center + radius * cos(phi)
                    )
            }
        }
        .frame(width: radius * 2, height: radius * 2)
    }
}

#Preview {
    ZStack {
        LabArcText(text: "SYDNEY", radius: 70, edge: .top)
        LabArcText(text: "AUSTRALIA", radius: 70, edge: .bottom)
    }
    .foregroundStyle(Color.ink)
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .paperBackground()
}
