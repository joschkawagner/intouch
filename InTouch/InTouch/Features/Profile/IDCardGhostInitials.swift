//
//  IDCardGhostInitials.swift
//  InTouch
//
//  The ghost portrait — a second, smaller impression of the holder, printed
//  beside the primary one.
//
//  A GHOST IS NOT A WATERMARK, and the difference is the whole point. A
//  watermark lives in the substrate, spans the document, and is compared to
//  nothing. A ghost portrait sits ADJACENT to the primary portrait at a
//  comparable scale, and that adjacency IS its security function: substituting
//  the photograph means matching the ghost too, and the two are checked by
//  being seen together. The first version of this file was a watermark wearing
//  a ghost's name — Jost 190 spanning the field block — which is exactly why it
//  read as a stray layer rather than as security printing, straight through the
//  name, handle and cities values.
//
//  So it is sized in relation to the PLATE, not the card; placed beside it; and
//  rhymes with it — same rectangle, same fill logic, same initials — so it
//  reads as a second impression of one element rather than a separate device.
//
//  QUALITY, NOT ELEMENT. The reference achieves this with a halftone portrait
//  screened into the substrate. There is no photograph here and, per the privacy
//  rules, no intention of processing one, so the initials carry the idea with
//  none of the borrowed imagery. When the photo model lands, this is the second
//  place a real portrait goes.
//
//  It belongs to the PRINTING layer: no label, no glow of its own, and it takes
//  the printing's day/UV ink policy so it can never become a second fluorescing
//  hero after dark.
//

import SwiftUI

struct IDCardGhostInitials: View {

    let initials: String
    /// Sized against the PLATE (180×278), not the card — roughly a quarter of
    /// its width, keeping the plate's portrait proportion.
    var size: CGSize = CGSize(width: 44, height: 66)

    @Environment(\.passportRenderMode) private var mode
    private var isUV: Bool { mode.isUV }

    var body: some View {
        ZStack {
            // Same fill logic as the plate, a step fainter — a second, lighter
            // impression of the same press.
            Rectangle()
                .fill(isUV ? PhotoSlotPolicy.uvFill.opacity(0.6)
                           : Color.ink.opacity(0.06))

            Text(initials)
                .font(Typography.idCardGhost)
                .foregroundStyle(
                    mode.printedInk(uv: .stampTeal, uvOpacity: 0.22, day: 0.16)
                )
                .minimumScaleFactor(0.6)
                .lineLimit(1)
        }
        .frame(width: size.width, height: size.height)
        .overlay(
            // Square corners, matching the plate rather than the card's
            // die-cut radius — it is an impression of the plate, not of the card.
            Rectangle()
                .strokeBorder(isUV ? Color.stampTeal.opacity(0.25)
                                   : Color.text.opacity(0.12),
                              lineWidth: 0.5)
        )
        .allowsHitTesting(false)
        .accessibilityHidden(true)   // decorative print, not content
    }
}
