//
//  IDCardView.swift
//  InTouch
//
//  The ID card as you meet it: lying sideways on the resting surface, so you
//  turn the phone to read it.
//
//  THE MECHANIC, AND WHY IT NEEDS NO ORIENTATION CODE. The app is portrait-
//  locked on iPhone (INFOPLIST_KEY_UISupportedInterfaceOrientations_iPhone =
//  Portrait), so the framebuffer never rotates. A FIXED rotationEffect is
//  therefore fixed relative to the DEVICE — turning the phone re-orients the
//  card relative to the world, with nothing observing anything.
//  DeviceOrientationModel exists because the book CHANGES between two states
//  (closed cover / open spread); a card that is permanently sideways has one
//  state and needs no observer.
//
//  WHY +90 AND NOT -90. It maps the card's left edge onto the screen's top, so
//  the portrait plate sits across the TOP in portrait and the field rows run
//  downward — the eye enters the object where it would if the card were
//  upright. The object is therefore COHERENT EVEN UNTURNED, which is the whole
//  weight-bearing argument for shipping no rotate hint. With -90 the plate
//  lands at the bottom and the fields read upward, which is what a broken
//  layout looks like.
//
//  ACCEPTED CONSEQUENCE: one turn direction is correct and the other shows the
//  card upside down. A real card also has one right way up — you rotate the
//  card, not your head. This is a decision, not a bug to discover later.
//
//  IPAD IS GATED OUT. iPad allows all four interface orientations, so there the
//  framebuffer DOES rotate and a fixed turn would be permanently wrong. The
//  check is a static idiom test, not an orientation observation, so the
//  "no orientation code" property survives intact.
//
//  NO ROTATE HINT — decided. The composition carries it instead: an ID-1 die-cut
//  with a radius-only shadow, centred on the resting surface with symmetric
//  margins, nothing else on screen, and chrome that is invariant under a quarter
//  turn. The shadow has NO y-offset on purpose: a directional shadow declares a
//  light source that would be wrong in one of the two holding positions, and it
//  is the detail that would most betray the fixed rotation.
//

import SwiftUI
import UIKit

struct IDCardView: View {

    let user: UserProfile

    /// The holder's record, passed through to the face for its CITIES count.
    /// A pass-through parameter rather than a lookup inside the face, for the
    /// same reason `PassportBookView` takes `holder` and `contents` instead of
    /// reaching for `MockData`: a value resolved implicitly is correct until
    /// something renders it where the implicit answer is wrong.
    let contents: PassportContents

    /// Only iPhone gets the fixed turn — see the header.
    private var turnsSideways: Bool {
        UIDevice.current.userInterfaceIdiom == .phone
    }

    var body: some View {
        GeometryReader { geo in
            let ref = IDCardMetrics.referenceSize
            // Turned a quarter, the card's on-screen HEIGHT is bounded by the
            // portrait screen's WIDTH. Fit against that, then rotate.
            let available = (turnsSideways ? geo.size.width : geo.size.height) - 48
            let scale = available / ref.height

            IDCardFront(user: user, contents: contents)
                .frame(width: ref.width, height: ref.height)
                .scaleEffect(scale, anchor: .center)
                .frame(width: ref.width * scale, height: ref.height * scale)
                .shadow(color: Color.text.opacity(0.32), radius: 13)
                .rotationEffect(.degrees(turnsSideways ? 90 : 0))
                .frame(width: geo.size.width, height: geo.size.height)
        }
    }
}
