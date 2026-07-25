//
//  MicroprintBand.swift
//  InTouch
//
//  Microprint — text set so small it reads as a hairline rule until you look
//  closely, then resolves into words. A real anti-forgery device. The design
//  runs "INTOUCH · INTOUCH · …" up the page gutter at 4pt in a faint ink.
//
//  This renders the band horizontally at its natural size; the caller rotates
//  and positions it (the security layer stands it up along a page edge).
//

import SwiftUI

struct MicroprintBand: View {

    /// One unit of the repeating band.
    var word = "INTOUCH"
    /// How many times to repeat it — enough to span the page edge once rotated.
    var repeatCount = 7
    /// The ink. Faint by design; the security layer sets the exact opacity.
    var color: Color

    private var line: String {
        Array(repeating: word, count: repeatCount).joined(separator: " · ")
    }

    var body: some View {
        Text(line)
            .font(Typography.passportMicroprint)
            .tracking(1)
            .foregroundStyle(color)
            .fixedSize()
            .lineLimit(1)
    }
}

#Preview {
    ZStack {
        Color.paper
        MicroprintBand(color: Color.ink.opacity(0.4))
            .rotationEffect(.degrees(-90))
    }
    .frame(width: 232, height: 330)
}
