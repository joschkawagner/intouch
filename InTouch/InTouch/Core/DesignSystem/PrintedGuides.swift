//
//  PrintedGuides.swift
//  InTouch
//
//  Faint printed guide dots, the way a real passport page is pre-ruled before
//  anything is stamped on it. DESIGN.md: "Passport page: grid of stamps on
//  `paper`, faint printed guides in `muted`."
//
//  Drawn with Canvas rather than a stack of Views: one draw pass, no layout
//  cost, and it scales to any page height without creating hundreds of views.
//

import SwiftUI

struct PrintedGuides: View {

    var spacing: CGFloat = 24
    var dotSize: CGFloat = 1.5

    var body: some View {
        Canvas { context, size in
            let colour = GraphicsContext.Shading.color(Color.muted.opacity(0.35))

            var y = spacing
            while y < size.height {
                var x = spacing
                while x < size.width {
                    let dot = Path(ellipseIn: CGRect(
                        x: x - dotSize / 2,
                        y: y - dotSize / 2,
                        width: dotSize,
                        height: dotSize
                    ))
                    context.fill(dot, with: colour)
                    x += spacing
                }
                y += spacing
            }
        }
        .allowsHitTesting(false)
    }
}

#Preview {
    PrintedGuides()
        .paperBackground()
}
