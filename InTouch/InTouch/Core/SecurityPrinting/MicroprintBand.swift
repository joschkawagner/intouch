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
            .tracking(Typography.machineTracking)
            .foregroundStyle(color)
            .fixedSize()
            .lineLimit(1)
            // Decorative printing, not content — hidden from VoiceOver for
            // exactly the reason the MRZ bands are (RULES.md R5): a texture
            // zone is not a reading zone. Heard aloud on hardware as
            // "INTOUCH · INTOUCH · …", once per band, before this landed.
            //
            // HIDDEN HERE, AT THE PRIMITIVE, DELIBERATELY. This single view is
            // positioned more than once per surface with caller-supplied
            // rotation — IDCardPrinting:117 horizontal, :121 rotated −90,
            // SecurityPrinting:163 likewise — so the two orientations a
            // VoiceOver user hears are one struct placed twice, not two views.
            // One modifier here covers every band in every orientation on both
            // documents; per-call-site fixes would drift apart.
            .accessibilityHidden(true)
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
