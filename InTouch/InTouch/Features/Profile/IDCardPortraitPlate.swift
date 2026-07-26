//
//  IDCardPortraitPlate.swift
//  InTouch
//
//  The card's portrait area — its own view, applying the shared photo-slot
//  POLICY rather than reusing the passport's photo-slot VIEW.
//
//  WHY NOT PassportPhotoSlot: compared aspect by aspect, the two share exactly
//  one of five. Same UV fill; different UV edge (that slot strokes all four
//  sides, this plate carries a keyline on ONE edge because it bleeds off the
//  other three), different daylight fill, different daylight content (a photo
//  placeholder glyph vs the holder's initials), and no Bauhaus frame here at
//  all. See DECISIONS.md 2026-07-25 — that view is back in Features/Passport
//  and only `PhotoSlotPolicy` is shared.
//
//  WHAT IS SHARED, via PhotoSlotPolicy:
//    • translucent in BOTH modes, so the security printing runs continuously
//      beneath the plate — the printing is on the card, it does not stop where
//      a portrait begins (anti-substitution; the UV reference shows contours
//      crossing the photograph).
//    • dark and unlit after dark, because photographs do not fluoresce. The
//      plate is emphatically NOT the card's hero — the name is.
//
//  IT BLEEDS off the card's left and bottom edges. A passport page's photo
//  block floats with margins on all four sides because a page is a leaf inside
//  something else; a card has edges of its own, and running the plate off two
//  of them is what makes it read as a die-cut object rather than a page.
//
//  When the photo model lands this is where a real photograph goes, washed by
//  PhotoSlotPolicy.uvPhotoDim after dark. The initials are the stand-in, not
//  the design.
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
//    • `PhotoSlotPolicy.uvPhotoDim` STILL HAS NO CONSUMER, so no capture can
//      catch a wrong value in it — a typo there would pass every gate silently.
//      It lands when the real photo model does.
//

import SwiftUI

struct IDCardPortraitPlate: View {

    let initials: String
    var size: CGSize = CGSize(width: 180, height: 278)
    /// Height reserved at the bottom for the machine strip, which IDCardFront
    /// overlays. The initials centre in the space ABOVE it, not in the plate.
    var machineStripHeight: CGFloat = 24

    @Environment(\.passportRenderMode) private var mode
    private var isUV: Bool { mode.isUV }

    var body: some View {
        ZStack(alignment: .topLeading) {
            Rectangle()
                .fill(isUV ? PhotoSlotPolicy.uvFill : Color.ink.opacity(0.10))

            Text(initials)
                .font(Typography.idCardInitials)
                .foregroundStyle(isUV ? Color.uvFieldLabel : Color.ink.opacity(0.85))
                .uvFieldLit(isUV)
                .frame(width: size.width,
                       height: size.height - machineStripHeight)

            // The plate's one edge. Only the trailing side gets a keyline —
            // the other three run off the card.
            Rectangle()
                .fill(isUV ? Color.stampTeal.opacity(0.5) : Color.text.opacity(0.25))
                .frame(width: 1, height: size.height)
                .offset(x: size.width - 1)
        }
        .frame(width: size.width, height: size.height)
        .clipped()
    }
}
