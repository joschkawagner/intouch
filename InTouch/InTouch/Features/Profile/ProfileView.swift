//
//  ProfileView.swift
//  InTouch
//
//  Your profile IS your ID card. Someone else's profile IS their passport.
//
//  THE REAL-WORLD MAPPING, which is the whole point: an ID card is identity
//  only — who you are, since when, under what number. A passport is the travel
//  record: the pages, the cities, the stamps. So your own profile shows your
//  ID, and the Passport tab holds your book. A connected person's profile shows
//  THEIR passport — you receive their record, not their papers — and there is
//  deliberately no ID for other people and no route between the two.
//
//  ⚠️ UNTIL NOW THAT PARAGRAPH DESCRIBED AN INTENTION, NOT THIS FILE. The view
//  rendered `IDCardView` unconditionally, with no branch — latent only because
//  both call sites passed the current user, and `MastheadView` hardcodes
//  `MockData.currentUser`, so no path COULD pass anyone else. The header made a
//  claim the code did not enforce, which is the same shape as `PassportHolder`'s
//  "must not touch anything outside the passport feature" (`b38dc21`) and
//  `PassportMockPhotos`' "no Core/Models changes" (`23fe2b4`): a comment
//  asserting a boundary the file never had. The branch below is the enforcement.
//
//  `isOwnProfile` IS AN EXPLICIT PARAMETER, NOT `profile.id == currentUser.id`.
//  Comparing here would mint a SECOND place that answers "am I me" — the first
//  being `PassportView`, whose header calls itself "the one place that answers
//  'me'" — and a second answer to one question is the exact shape `4a3c65b`
//  deleted from `UserProfile.cityCount`. It would also have this view reach for
//  `MockData`, which is what the `PassportContents` seam exists to stop. Same
//  standing rule as `PassportCoverView`'s "⚠️ `user` HAS NO DEFAULT" and
//  `PassportPagingControls`' "an explicit parameter cannot be forgotten at a
//  call site".
//
//  THE RESTING SURFACE IS INSIDE THE BRANCH, and that is not tidiness. The card
//  needs a surface to lie on; `PassportBookView` DRAWS ITS OWN (`:57`). Drawing
//  one here as well would composite `CornerVignettes` twice — ~0.10 over ~0.10
//  at the corners — so the book would sit in a visibly darker frame than the one
//  the Passport tab renders, for no reason anyone could find later.
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
//  ⚠️ fullScreenCover HAS NO SWIPE-TO-DISMISS. The X is the only exit, which
//  makes it load-bearing rather than decorative — it is gated on being present
//  and tappable in the ACCESSIBILITY TREE, not merely visible on screen. A9's
//  lesson was that untraversable UI is untestable UI, and the passport
//  chevrons failed in exactly that way.
//
//  THE CHROME IS IN-PAGE, NOT A SYSTEM TOOLBAR — twice over. First, the app's
//  standing convention (see MastheadView): chrome drawn in-page keeps every
//  type and colour decision inside the design system, and the toolbar this
//  view briefly carried was the app's FIRST system toolbar, adopted without
//  noticing it broke that rule. Second, measured: the system toolbar's
//  material-backed buttons render differently on every launch (DECISIONS.md
//  2026-07-26 — twelve launches, twelve distinct hashes; toolbar removed,
//  byte-identical 3/3 across a rebuild), which made this screen the only one
//  in the app that could not be pixel-gated. The buttons keep the passport
//  chevrons' register: Typography.body symbols, mode-aware ink, no material.
//

import SwiftUI

struct ProfileView: View {

    let profile: UserProfile

    /// The holder's record — the card's CITIES count, or the whole of someone
    /// else's book. Threaded from the presenting screen rather than looked up
    /// here, so that this view names no fixture and the count has exactly one
    /// source.
    let contents: PassportContents

    /// Whose profile this is. `true` shows the ID card, `false` shows the
    /// holder's passport. See the file header for why this is a parameter and
    /// not an identity comparison made here.
    let isOwnProfile: Bool

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
                if isOwnProfile {
                    PassportRestingSurface()
                        .ignoresSafeArea()

                    IDCardView(user: profile, contents: contents)
                } else {
                    // No resting surface here — the book brings its own.
                    PassportBookView(holder: profile, contents: contents)
                }
            }
            .environment(\.passportRenderMode, mode)
            .toolbar(.hidden, for: .navigationBar)
            .overlay(alignment: .topLeading) {
                Button { dismiss() } label: {
                    Image(systemName: "xmark")
                        .font(Typography.body)
                        .foregroundStyle(chromeTint)
                        .frame(width: 44, height: 44)
                        .contentShape(Rectangle())
                }
                .accessibilityLabel("Close")
                .padding(8)
            }
            // The gear is YOURS. Settings is account, privacy, blocked users and
            // sign-out — none of which is a fact about the person whose passport
            // you are holding, so it does not appear on their profile.
            .overlay(alignment: .topTrailing) {
                if isOwnProfile {
                    NavigationLink { SettingsView() } label: {
                        Image(systemName: "gearshape")
                            .font(Typography.body)
                            .foregroundStyle(chromeTint)
                            .frame(width: 44, height: 44)
                            .contentShape(Rectangle())
                    }
                    .accessibilityLabel("Settings")
                    .padding(8)
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

#Preview("Mine — the ID card") {
    ProfileView(profile: MockData.currentUser, contents: .currentUser, isOwnProfile: true)
}

/// Someone else's profile: the same screen, the other document.
///
/// In a preview the phone never rotates, so this shows Nora's CLOSED COVER —
/// the book opens on physical landscape (`DeviceOrientationModel`). What it
/// proves is the branch and the threading: her name on her cover, from her
/// `UserProfile`, with her derived record behind it. Her pages are reachable
/// from the previews in `PassportBookView` and `PassportColophonPage`.
#Preview("Nora's — her passport") {
    ProfileView(profile: MockData.friendNora, contents: .nora, isOwnProfile: false)
}
