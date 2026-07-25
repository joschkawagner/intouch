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
        .sheet(isPresented: $showingProfile) {
            ProfileView(profile: MockData.currentUser, isCurrentUser: true)
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
