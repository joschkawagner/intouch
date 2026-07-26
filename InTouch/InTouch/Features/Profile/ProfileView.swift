//
//  ProfileView.swift
//  InTouch
//
//  Your profile IS your ID card. Not a collage, not a passport.
//
//  THE REAL-WORLD MAPPING, which is the whole point: an ID card is identity
//  only — who you are, since when, under what number. A passport is the travel
//  record: the pages, the cities, the stamps. So your own profile shows your
//  ID, and the Passport tab holds your book. A connected person's profile shows
//  THEIR passport — you receive their record, not their papers — and there is
//  deliberately no ID for other people and no route between the two. Keep it
//  simple until there's a reason not to.
//
//  This supersedes PRD §4.5's "your profile IS your passport booklet" and the
//  hand-assembled-collage profile that stood here before. The collage survives
//  where it still belongs: scan results, events and groups.
//
//  The card renders IMMEDIATELY, sideways — never hidden behind a rotation.
//  That is the deliberate contrast with the passport, where portrait shows a
//  closed cover and turning the phone OPENS it. Here turning is only for
//  legibility; the object is fully present either way. See IDCardView.
//
//  Chrome is deliberately minimal and quarter-turn-invariant: `xmark` is
//  rotationally symmetric at 90°, `gearshape` has 8-fold symmetry. A chevron or
//  a word label would break the illusion the moment the phone turned.
//
//  THE STATUS BAR IS HIDDEN HERE, and it took a presentation change to do it.
//  `.statusBarHidden(true)` alone had no effect under `.sheet`, tried both
//  inside and outside the NavigationStack — a sheet does not own the status
//  bar. Presented as a `.fullScreenCover` (see MastheadView) the modifier
//  takes. A sideways status bar is the worst possible artifact for an object
//  whose whole claim is "deliberately placed, not broken", and its live clock
//  also made the card impossible to baseline: the full-frame hash changed
//  every minute by construction.
//
//  ⚠️ fullScreenCover HAS NO SWIPE-TO-DISMISS. The toolbar X is the only exit,
//  which makes it load-bearing rather than decorative — it is gated on being
//  present and tappable in the ACCESSIBILITY TREE, not merely visible on
//  screen. A9's lesson was that untraversable UI is untestable UI, and the
//  passport chevrons failed in exactly that way.
//

import SwiftUI

struct ProfileView: View {

    let profile: UserProfile

    @Environment(\.dismiss) private var dismiss
    @State private var clock = PassportTimeOfDay()

    /// The card follows the same day/UV clock as the book — one object, two
    /// lighting states, applied to both documents.
    private var mode: PassportRenderMode {
        #if DEBUG
        if let forced = DebugUV.shared.forced { return forced }
        #endif
        return clock.renderMode
    }

    /// Toolbar marks have to survive the card's ground changing under them:
    /// `ink` is invisible on `uvGround`.
    private var chromeTint: Color {
        mode.isUV ? Color.paper.opacity(0.55) : Color.ink
    }

    var body: some View {
        NavigationStack {
            ZStack {
                PassportRestingSurface()
                    .ignoresSafeArea()

                IDCardView(user: profile)
            }
            .environment(\.passportRenderMode, mode)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button { dismiss() } label: {
                        Image(systemName: "xmark").foregroundStyle(chromeTint)
                    }
                    .accessibilityLabel("Close")
                }
                ToolbarItem(placement: .topBarTrailing) {
                    NavigationLink { SettingsView() } label: {
                        Image(systemName: "gearshape").foregroundStyle(chromeTint)
                    }
                    .accessibilityLabel("Settings")
                }
            }
            #if DEBUG
            .overlay(alignment: .bottomTrailing) { DebugUVChip().padding(8) }
            #endif
            .onAppear { clock.start() }
            .onDisappear { clock.stop() }
        }
        .statusBarHidden(true)
    }
}

#Preview {
    ProfileView(profile: MockData.currentUser)
}
