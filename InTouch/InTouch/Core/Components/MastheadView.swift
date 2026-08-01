//
//  MastheadView.swift
//  InTouch
//
//  The header at the top of each main tab.
//
//  Drawn in-page rather than using a system navigation bar. A UIKit nav bar can
//  only be restyled through UINavigationBarAppearance proxies, which means font and
//  colour decisions leaking out of the design system into app setup code. An
//  in-page masthead keeps every type and colour choice inside DesignSystem.
//
//  The profile avatar and its sheet live *here*, so all four main screens get the
//  entry point for free — change it once, it updates everywhere. Titles run through
//  Typography.chrome(), so the lowercaseChrome flag flips the whole app's case.
//

import SwiftUI

struct MastheadView: View {

    let title: String

    /// Small letterspaced detail line — a count, a status. Passport form field.
    let detail: String

    @State private var showingProfile = false

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(Typography.chrome(detail))
                .font(Typography.label)
                .tracking(Typography.stampTracking)
                .foregroundStyle(Color.muted)

            HStack(alignment: .center) {
                Text(Typography.chrome(title))
                    .font(Typography.masthead)
                    .foregroundStyle(Color.ink)

                Spacer()

                Button { showingProfile = true } label: {
                    AvatarView(initials: MockData.currentUser.initials, diameter: 34)
                }
                .accessibilityLabel("Your profile")
            }

            Rectangle()
                .fill(Color.muted.opacity(0.5))
                .frame(height: 1)
                .padding(.top, 8)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 20)
        .padding(.top, 8)
        .padding(.bottom, 14)
        // fullScreenCover, not sheet. The card is a quarter-turned object filling
        // the screen, and a sheet keeps the status bar in frame — a sideways
        // status bar is the single most "this app is confused" artifact possible,
        // and its live clock also made the card impossible to baseline, since the
        // full-frame hash changed every minute. `.statusBarHidden(true)` was tried
        // under `.sheet` both inside and outside the NavigationStack and had no
        // effect; the presentation style is what carries it.
        //
        // ACCEPTED CONSEQUENCE: fullScreenCover has no swipe-to-dismiss, so the
        // toolbar X is the ONLY way out. That is why it is gated on being present
        // and tappable in the accessibility tree, not merely visible.
        .fullScreenCover(isPresented: $showingProfile) {
            // The record travels with the person: the card's CITIES field is a
            // count of the holder's cities, and `PassportContents` is where they
            // live. Deliberately NOT a bare `Int` computed here — that would put
            // a second answer to "how many cities" at the presentation layer,
            // which is the exact shape of the stored `cityCount` this replaced.
            ProfileView(profile: MockData.currentUser, contents: .currentUser)
        }
    }
}

#Preview {
    VStack {
        MastheadView(title: "Passport", detail: "\(MockData.cities.count) cities")
        Spacer()
    }
    .paperBackground()
}
