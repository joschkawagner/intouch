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
//  After dark (2a·uv): all fields render calm per the field-glow rule (see
//  Palette.swift, UV inks) — this page's one hero is the name + photo block,
//  fluorescing violet. The MRZ belongs to the machine/printing layer, not the
//  field system, so it keeps its own fluorescence.
//

import SwiftUI

struct PassportIdentityPage: View {

    let user: UserProfile

    @Environment(\.passportRenderMode) private var mode
    private var isUV: Bool { mode.isUV }

    var body: some View {
        PassportPage(security: .standard, seed: "identity") {
            ZStack {
                photoBlock
                    .frame(width: 90, height: 116)
                    .referenceOrigin(x: 14, y: 36)

                // Name + handle, to the right of the photo. Labels sit 16pt
                // above their value (the document-form breathing room; a 12pt
                // gap set the value inside the label's own line box).
                label("name").referenceOrigin(x: 114, y: 36)
                Text(user.displayName)
                    .font(Typography.passportName)
                    .foregroundStyle(isUV ? Color.stampViolet : Color.ink)
                    .fluoresce(isUV ? Color.stampViolet : .clear)
                    .referenceOrigin(x: 114, y: 52)

                label("handle").referenceOrigin(x: 114, y: 88)
                Text(Typography.chrome(user.handle))
                    .font(Typography.passportLabel)
                    .foregroundStyle(isUV ? Color.uvFieldValue : Color.muted)
                    .referenceOrigin(x: 114, y: 104)

                // Since + holder number, a row beneath the photo.
                label("since").referenceOrigin(x: 14, y: 164)
                stamp(Self.joinedString(user.joinedDate)).referenceOrigin(x: 14, y: 180)

                label("holder no.").referenceOrigin(x: 118, y: 164)
                stamp(PassportHolder.formattedNumber).referenceOrigin(x: 118, y: 180)

                // Bio.
                label("bio").referenceOrigin(x: 14, y: 210)
                Text(user.bio)
                    .font(Typography.passportBody)
                    .foregroundStyle(isUV ? Color.uvFieldValue : Color.text)
                    .frame(width: 204, alignment: .leading)
                    .referenceOrigin(x: 14, y: 226)

                // MRZ machine band along the bottom edge.
                mrzBand.referenceOrigin(x: 0, y: 300)
            }
        }
    }

    // MARK: - Photo block

    @ViewBuilder
    private var photoBlock: some View {
        if isUV {
            ZStack {
                Rectangle().strokeBorder(Color.stampViolet, lineWidth: 1.5)
                Text(user.initials)
                    .font(Typography.passportAvatarInitials)
                    .foregroundStyle(Color.stampViolet)
                    .fluoresce(Color.stampViolet)
            }
            .fluoresce(Color.stampViolet)
        } else {
            ZStack {
                Rectangle().fill(Color.ink)
                Text(user.initials)
                    .font(Typography.passportAvatarInitials)
                    .foregroundStyle(Color.paper)
            }
        }
    }

    // MARK: - Field pieces

    /// A struck uppercase field label — passport-form style, not nav chrome.
    private func label(_ text: String) -> some View {
        Text(text.uppercased())
            .font(Typography.passportLabel)
            .tracking(Typography.stampTracking)
            .foregroundStyle(isUV ? Color.uvFieldLabel : Color.text.opacity(0.5))
    }

    /// A machine-type value (Courier) — calm in both modes per the field-glow
    /// rule; this page's hero is the name + photo block, nothing else glows.
    private func stamp(_ text: String) -> some View {
        Text(text)
            .font(Typography.timestamp)
            .tracking(Typography.stampTracking)
            .foregroundStyle(isUV ? Color.uvFieldValue : Color.text)
    }

    private var mrzBand: some View {
        ZStack(alignment: .leading) {
            Rectangle().fill(isUV ? Color.paper.opacity(0.03) : Color.text.opacity(0.04))
            Text(PassportHolder.mrz(name: user.displayName))
                .font(Typography.passportCoord)
                .tracking(1.5)
                .foregroundStyle(isUV ? Color.stampRed : Color.text.opacity(0.4))
                .fluoresce(isUV ? Color.stampRed : .clear)
                .lineLimit(1)
                .padding(.leading, 14)
        }
        .frame(width: 232, height: 20)
        .overlay(alignment: .top) {
            Rectangle()
                .fill(isUV ? Color.stampRed.opacity(0.3) : Color.text.opacity(0.12))
                .frame(height: 1)
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
    HStack(spacing: 16) {
        PassportIdentityPage(user: MockData.currentUser)
            .frame(width: 232, height: 330)
            .environment(\.passportRenderMode, .daylight)
        PassportIdentityPage(user: MockData.currentUser)
            .frame(width: 232, height: 330)
            .environment(\.passportRenderMode, .uv)
    }
    .padding()
    .background(Color.muted)
}
