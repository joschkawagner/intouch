//
//  CornerVignettes.swift
//  InTouch
//
//  The four soft corner shadows the design paints into every passport surface —
//  the resting surface the book floats on, and the cover material itself. Each
//  corner gets a radial darkening that fades to nothing part-way across the
//  page, so a flat fill reads as a lit object with a little depth.
//
//  `reach` is the fraction of the surface's diagonal at which the darkening has
//  faded out (the design uses 0.35 on the resting surface, 0.24 on the cover).
//

import SwiftUI

struct CornerVignettes: View {

    var color: Color
    var reach: CGFloat

    private let corners: [UnitPoint] = [.topLeading, .topTrailing, .bottomLeading, .bottomTrailing]

    var body: some View {
        GeometryReader { geo in
            let end = hypot(geo.size.width, geo.size.height) * reach
            ZStack {
                ForEach(corners.indices, id: \.self) { i in
                    RadialGradient(
                        colors: [color, .clear],
                        center: corners[i],
                        startRadius: 0,
                        endRadius: end
                    )
                }
            }
        }
        .allowsHitTesting(false)
    }
}

#Preview {
    ZStack {
        Color.muted
        CornerVignettes(color: Color.text.opacity(0.10), reach: 0.35)
    }
    .frame(width: 300, height: 500)
}
