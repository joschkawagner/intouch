//
//  ArcText.swift
//  InTouch
//
//  Text curved along a circle, centred at the top. Used for the city name on
//  a stamp.
//
//  SwiftUI has no curved text, so each character is placed by hand:
//    1. Measure the character's width in the real font (this is why Typography
//       exposes UIFont — you cannot measure a SwiftUI `Font`).
//    2. Convert that width to an angle along the arc: angle = width / radius.
//    3. Push the glyph up by `radius`, then rotate it.
//
//  Step 3 is the trick worth remembering: `.offset` moves what's drawn but not
//  the view's layout frame, and `.rotationEffect` spins around that unmoved
//  frame's centre. So offset-then-rotate swings the glyph around the circle AND
//  tangents it to the curve in one go. Reverse the two and you get a glyph that
//  spins in place.
//

import SwiftUI
import UIKit

struct ArcText: View {

    let text: String

    /// Distance from the centre of the circle to the centre of each glyph.
    let radius: CGFloat

    var uiFont: UIFont = Typography.stampCityUIFont
    var tracking: CGFloat = Typography.stampTracking

    private var characters: [Character] { Array(text) }

    /// Advance width of each character, including its share of letterspacing.
    private var widths: [CGFloat] {
        characters.map { character in
            let size = (String(character) as NSString)
                .size(withAttributes: [.font: uiFont])
            return size.width + tracking
        }
    }

    var body: some View {
        let widths = self.widths
        let totalAngle = widths.reduce(0, +) / radius   // radians

        ZStack {
            ForEach(Array(characters.enumerated()), id: \.offset) { index, character in
                let precedingWidth = widths[..<index].reduce(0, +)
                let centreOffset = precedingWidth + widths[index] / 2
                let angle = centreOffset / radius - totalAngle / 2

                Text(String(character))
                    .font(Font(uiFont))
                    .offset(y: -radius)
                    .rotationEffect(.radians(angle))
            }
        }
        .frame(width: radius * 2, height: radius * 2)
    }
}

#Preview {
    ArcText(text: "ZÜRICH", radius: 52)
        .foregroundStyle(Color.ink)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .paperBackground()
}
