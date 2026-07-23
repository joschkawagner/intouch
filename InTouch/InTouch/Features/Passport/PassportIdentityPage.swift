//
//  PassportIdentityPage.swift
//  InTouch
//
//  The left page of the passport's first spread — the holder's identity, in the
//  register of a passport's photo page: portrait, name, the details beneath.
//  Photo is the initials avatar for now (no photo field yet); `AvatarView` keeps
//  the real image as a later drop-in.
//

import SwiftUI

struct PassportIdentityPage: View {

    let user: UserProfile

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            AvatarView(initials: user.initials, diameter: 96)

            Text(user.displayName)
                .font(Typography.masthead)
                .foregroundStyle(Color.ink)
                .padding(.top, 20)

            Text(Typography.chrome(user.handle))
                .font(Typography.label)
                .tracking(1)
                .foregroundStyle(Color.muted)
                .padding(.top, 4)

            Text(Self.joinedString(user.joinedDate))
                .font(Typography.timestamp)
                .tracking(1)
                .foregroundStyle(Color.text)
                .padding(.top, 16)

            Text(user.bio)
                .font(Typography.body)
                .foregroundStyle(Color.text)
                .padding(.top, 12)

            Spacer(minLength: 0)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .padding(28)
        .paperBackground()
    }

    /// e.g. "SINCE SEP 2025" — Courier, machine type, matches the passport look.
    private static let formatter: DateFormatter = {
        let f = DateFormatter()
        f.locale = Locale(identifier: "en_US_POSIX")
        f.dateFormat = "MMM yyyy"
        return f
    }()

    private static func joinedString(_ date: Date) -> String {
        "SINCE " + formatter.string(from: date).uppercased()
    }
}

#Preview {
    PassportIdentityPage(user: MockData.currentUser)
}
