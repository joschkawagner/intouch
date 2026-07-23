//
//  PassportIdentityPage.swift
//  InTouch
//
//  The left page of the passport's first spread — the holder's identity in a
//  passport photo-page register (design 2a): a rectangular photo block with the
//  holder's initials, a grid of struck fields (name, handle, since, holder no.,
//  bio), and the machine-readable (MRZ) band along the bottom edge.
//
//  Laid out at the 232×330 reference (see PassportPage) with each field pinned to
//  its design coordinate via `referenceOrigin`. Field labels are set uppercase
//  and letterspaced like a real document form — deliberately not the app's
//  lowercase nav chrome. Holder number + MRZ are mocked in-feature (PassportHolder).
//

import SwiftUI

struct PassportIdentityPage: View {

    let user: UserProfile

    var body: some View {
        PassportPage(security: .standard) {
            ZStack {
                // Photo block — a rectangular oxblood field with the initials,
                // the passport-photo register (replaces the round avatar).
                ZStack {
                    Rectangle().fill(Color.ink)
                    Text(user.initials)
                        .font(Typography.passportAvatarInitials)
                        .foregroundStyle(Color.paper)
                }
                .frame(width: 90, height: 116)
                .referenceOrigin(x: 14, y: 36)

                // Name + handle, to the right of the photo.
                label("name").referenceOrigin(x: 114, y: 36)
                Text(user.displayName)
                    .font(Typography.passportName)
                    .foregroundStyle(Color.ink)
                    .referenceOrigin(x: 114, y: 48)

                label("handle").referenceOrigin(x: 114, y: 86)
                Text(Typography.chrome(user.handle))
                    .font(Typography.passportLabel)
                    .foregroundStyle(Color.muted)
                    .referenceOrigin(x: 114, y: 98)

                // Since + holder number, a row beneath the photo.
                label("since").referenceOrigin(x: 14, y: 166)
                stamp(Self.joinedString(user.joinedDate)).referenceOrigin(x: 14, y: 178)

                label("holder no.").referenceOrigin(x: 118, y: 166)
                stamp(PassportHolder.formattedNumber).referenceOrigin(x: 118, y: 178)

                // Bio.
                label("bio").referenceOrigin(x: 14, y: 206)
                Text(user.bio)
                    .font(Typography.passportBody)
                    .foregroundStyle(Color.text)
                    .frame(width: 204, alignment: .leading)
                    .referenceOrigin(x: 14, y: 218)

                // MRZ machine band along the bottom edge.
                mrzBand.referenceOrigin(x: 0, y: 300)
            }
        }
    }

    // MARK: - Field pieces

    /// A struck uppercase field label — passport-form style, not nav chrome.
    private func label(_ text: String) -> some View {
        Text(text.uppercased())
            .font(Typography.passportLabel)
            .tracking(Typography.stampTracking)
            .foregroundStyle(Color.text.opacity(0.5))
    }

    /// A machine-type value (Courier) for dates and numbers.
    private func stamp(_ text: String) -> some View {
        Text(text)
            .font(Typography.timestamp)
            .tracking(Typography.stampTracking)
            .foregroundStyle(Color.text)
    }

    private var mrzBand: some View {
        ZStack(alignment: .leading) {
            Rectangle().fill(Color.text.opacity(0.04))
            Text(PassportHolder.mrz(name: user.displayName))
                .font(Typography.passportCoord)
                .tracking(1.5)
                .foregroundStyle(Color.text.opacity(0.4))
                .lineLimit(1)
                .padding(.leading, 14)
        }
        .frame(width: 232, height: 20)
        .overlay(alignment: .top) {
            Rectangle().fill(Color.text.opacity(0.12)).frame(height: 1)
        }
        .clipped()
    }

    /// e.g. "SEP 2025" — Courier machine type, the value under the "since" label.
    private static let formatter: DateFormatter = {
        let f = DateFormatter()
        f.locale = Locale(identifier: "en_US_POSIX")
        f.dateFormat = "MMM yyyy"
        return f
    }()

    private static func joinedString(_ date: Date) -> String {
        formatter.string(from: date).uppercased()
    }
}

#Preview {
    PassportIdentityPage(user: MockData.currentUser)
        .frame(width: 232, height: 330)
        .padding()
        .background(Color.muted)
}
