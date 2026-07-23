//
//  PassportSpineSeal.swift
//  InTouch
//
//  A hidden mark that only appears after dark (design 2a·uv): a fluorescing
//  guilloché seal straddling the spine of the open identity spread, with the
//  brand mantra beneath it. Invisible in daylight — it is drawn only in UV,
//  where it reads as the security reveal at the centre of the book.
//

import SwiftUI

struct PassportSpineSeal: View {
    var body: some View {
        VStack(spacing: 10) {
            GuillocheRosette(fixedRadius: 60, rollingRadius: 12, penOffset: 34)
                .stroke(Color.stampViolet.opacity(0.6), lineWidth: 0.8)
                .frame(width: 76, height: 76)
                .shadow(color: Color.stampViolet.opacity(0.7), radius: 5)

            Text(Typography.chrome("you had to be there"))
                .font(Typography.passportLabel)
                .tracking(Typography.stampTracking)
                .foregroundStyle(Color.stampViolet)
                .shadow(color: Color.stampViolet.opacity(0.8), radius: 4)
        }
        .allowsHitTesting(false)
    }
}

#Preview {
    ZStack {
        Color.uvGround
        PassportSpineSeal()
    }
    .frame(width: 300, height: 300)
}
