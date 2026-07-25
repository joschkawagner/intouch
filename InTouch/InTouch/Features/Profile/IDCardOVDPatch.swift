//
//  IDCardOVDPatch.swift
//  InTouch
//
//  The optically-variable patch — the small area of a real card that shifts
//  colour and pattern as it tilts (kinegram, hologram, OVI).
//
//  QUALITY, NOT ELEMENT. The reference carries a die-shaped foil patch stamped
//  with national imagery. What transfers is the IDEA: a discrete, bounded area
//  of the card that behaves like a different material from the paper around it.
//  What does not transfer is any of its content. This is guilloché lace inside
//  a rounded die-cut, which is our own vocabulary already used on every
//  passport page.
//
//  PRINTING, NOT A FIELD. It carries no label and takes the printing layer's
//  day/UV ink policy, so it cannot become a second fluorescing hero after dark
//  — the card gets exactly one (the name).
//
//  No animation. A real OVD shifts with viewing angle; faking that with motion
//  would be the kind of decoration this design refuses, and the app's motion
//  rule is mechanical-not-bouncy anyway. It reads as a patch because of its
//  boundary and its different linework, not because it moves.
//
//  ⚠️ NOT YET VERIFIED — nothing renders this. Everything about the ID card
//  except its terrain density is unverified until it is wired into ProfileView.
//

import SwiftUI

struct IDCardOVDPatch: View {

    var size: CGSize = CGSize(width: 65, height: 64)
    var cornerRadius: CGFloat = 8

    @Environment(\.passportRenderMode) private var mode
    private var isUV: Bool { mode.isUV }

    var body: some View {
        ZStack {
            // The patch's own substrate — a faint warm sheen by day (foil
            // catching light), near-nothing after dark.
            RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                .fill(isUV ? Color.uvCell.opacity(0.35) : Color.aged.opacity(0.10))

            // Two rosettes at different radii: the interference between them is
            // what reads as "this area is a different material".
            GuillocheRosette(fixedRadius: 34, rollingRadius: 7, penOffset: 18)
                .stroke(mode.printedInk(uv: .stampViolet, uvOpacity: 0.34, day: 0.09),
                        lineWidth: 0.5)

            GuillocheRosette(fixedRadius: 28, rollingRadius: 11, penOffset: 13)
                .stroke(mode.printedInk(uv: .stampCobalt, uvOpacity: 0.30, day: 0.07),
                        lineWidth: 0.5)
        }
        .frame(width: size.width, height: size.height)
        .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                .strokeBorder(mode.printedInk(uv: .stampGold, uvOpacity: 0.40, day: 0.10),
                              lineWidth: 0.5)
        )
        .allowsHitTesting(false)
        .accessibilityHidden(true)   // decorative print, not content
    }
}
