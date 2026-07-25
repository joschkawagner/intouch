//
//  IDCardGhostInitials.swift
//  InTouch
//
//  The watermarked repeat of the holder's initials, printed into the security
//  tint — the card's equivalent of the reference's ghosted second portrait,
//  which repeats the bearer at low contrast across the document's middle.
//
//  QUALITY, NOT ELEMENT. The reference achieves this with a halftone portrait
//  screened into the substrate. We have no photograph and (per the privacy
//  rules) no intention of processing one, so the holder's initials stand in —
//  the same idea, the same anti-substitution purpose, none of the borrowed
//  imagery.
//
//  It belongs to the PRINTING layer, not the field system: no label, no glow of
//  its own, and it takes the printing's day/UV ink policy so it can never
//  become a second fluorescing hero after dark.
//
//  Kept a separate view rather than folded into IDCardPrinting, because it is
//  the one printing element that depends on CONTENT (the holder's initials).
//  Threading a name through IDCardPrinting would push that dependency up
//  through IDCardFace, which has no business knowing who the holder is.
//
//  ⚠️ NOT YET VERIFIED — nothing renders this. Everything about the ID card
//  except its terrain density is unverified until it is wired into ProfileView.
//

import SwiftUI

struct IDCardGhostInitials: View {

    let initials: String

    @Environment(\.passportRenderMode) private var mode

    var body: some View {
        Text(initials)
            .font(Typography.idCardGhost)
            .foregroundStyle(
                mode.printedInk(uv: .stampTeal, uvOpacity: 0.20, day: 0.05)
            )
            .fixedSize()
            .allowsHitTesting(false)
            .accessibilityHidden(true)   // decorative print, not content
    }
}
