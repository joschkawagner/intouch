//
//  IDCardMachineStrip.swift
//  InTouch
//
//  The card's machine-readable strip.
//
//  DIFFERENT PLACEMENT FROM THE PASSPORT, deliberately. The identity page runs
//  a full-width MRZ along the bottom edge of the leaf — a book's machine zone.
//  The card's strip is short and sits INSIDE the portrait plate, reading as
//  engraved into the portrait window rather than banded across the base. Same
//  vocabulary, different object.
//
//  The string is clipped rather than wrapped or shrunk: a machine band runs off
//  its own edge, and `PassportHolder.mrz(for:)` pads up to 44 characters but
//  never truncates, so a long name simply runs past the clip. That is correct
//  behaviour for the artifact, not an overflow bug.
//
//  UV: the strip belongs to the machine/printing layer, NOT the field system,
//  so it fluoresces independently in stampRed while every field stays calm —
//  the same exemption the book's MRZ has (see the field-glow rule in
//  Palette.swift).
//
//  ✅ RENDERED AND SEEN as of f09c2eb — the card is wired into ProfileView and
//  has run in the simulator in both lighting modes. ⚠️ What that does NOT cover,
//  and must not be assumed from it:
//    • ROUTE STABILITY of the card's own render is UNESTABLISHED. Tap ordering
//      selects between stable render outcomes elsewhere in this app and the
//      cause is unknown (DECISIONS.md 2026-07-25). The card is reached by a
//      brand-new path and has not been captured by two routes and compared.
//    • NO BASELINE EXISTS. The status bar is still in frame, so the card's
//      full-frame hash changes every minute by construction.
//    • MICROPRINT DENSITY is container-dependent — see IDCardPrinting.
//    • Q3 (the empty col-B row 3) and Q4 (bio wrap on a long bio) are OPEN.
//      Q4 bears on THIS file too: the clip behaviour on a long name is reasoned
//      above but has never been seen with a name long enough to reach the clip.
//

import SwiftUI

struct IDCardMachineStrip: View {

    /// The holder whose band this is. Takes the whole person rather than a
    /// name, because the band encodes the name AND the serial, and the serial
    /// now belongs to the holder rather than to a shared literal.
    let user: UserProfile
    /// Strip width — the portrait plate's width at the card reference.
    var width: CGFloat = 180
    var height: CGFloat = 24

    @Environment(\.passportRenderMode) private var mode
    private var isUV: Bool { mode.isUV }

    var body: some View {
        ZStack(alignment: .leading) {
            Rectangle()
                .fill(isUV ? Color.paper.opacity(0.03) : Color.text.opacity(0.04))

            Text(PassportHolder.mrz(for: user))
                .font(Typography.passportCoord)
                .tracking(Typography.mrzTracking)
                .foregroundStyle(isUV ? Color.stampRed : Color.text.opacity(0.4))
                .fluoresce(isUV ? Color.stampRed : .clear)
                .lineLimit(1)
                .padding(.leading, 14)
        }
        .frame(width: width, height: height)
        .overlay(alignment: .top) {
            Rectangle()
                .fill(isUV ? Color.stampRed.opacity(0.3) : Color.text.opacity(0.12))
                .frame(height: 1)
        }
        .clipped()
        // Machine zone, not a reading zone — the same call as the book's MRZ
        // band. VoiceOver would spell out "JOSCHKA<WAGNER<<INT<1924<<<<…" one
        // character at a time, and every field it encodes is already announced
        // in plain language by the labelled rows beside it.
        .accessibilityHidden(true)
    }
}
