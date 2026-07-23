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
//  After dark (2a·uv): the routine fields dim to a faint paper white; the name,
//  holder number and MRZ fluoresce (violet / teal with a glow); the photo block
//  becomes a glowing violet outline instead of a solid ink fill.
//

import SwiftUI

struct PassportIdentityPage: View {

    let user: UserProfile

    @Environment(\.passportRenderMode) private var mode
    private var isUV: Bool { mode.isUV }

    var body: some View {
        PassportPage(security: .standard) {
            ZStack {
                photoBlock
                    .frame(width: 90, height: 116)
                    .referenceOrigin(x: 14, y: 36)

                // Name + handle, to the right of the photo.
                label("name").referenceOrigin(x: 114, y: 36)
                Text(user.displayName)
                    .font(Typography.passportName)
                    .foregroundStyle(isUV ? Color.stampViolet : Color.ink)
                    .glow(isUV ? Color.stampViolet : .clear)
                    .referenceOrigin(x: 114, y: 48)

                label("handle").referenceOrigin(x: 114, y: 86)
                Text(Typography.chrome(user.handle))
                    .font(Typography.passportLabel)
                    .foregroundStyle(isUV ? Color.paper.opacity(0.3) : Color.muted)
                    .referenceOrigin(x: 114, y: 98)

                // Since + holder number, a row beneath the photo.
                label("since").referenceOrigin(x: 14, y: 166)
                stamp(Self.joinedString(user.joinedDate), dim: true).referenceOrigin(x: 14, y: 178)

                label("holder no.").referenceOrigin(x: 118, y: 166)
                stamp(PassportHolder.formattedNumber, dim: false).referenceOrigin(x: 118, y: 178)

                // Bio.
                label("bio").referenceOrigin(x: 14, y: 206)
                Text(user.bio)
                    .font(Typography.passportBody)
                    .foregroundStyle(isUV ? Color.paper.opacity(0.22) : Color.text)
                    .frame(width: 204, alignment: .leading)
                    .referenceOrigin(x: 14, y: 218)

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
                    .glow(Color.stampViolet)
            }
            .glow(Color.stampViolet)
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
            .foregroundStyle(isUV ? Color.paper.opacity(0.18) : Color.text.opacity(0.5))
    }

    /// A machine-type value (Courier). `dim` values stay quiet after dark;
    /// non-dim values (the holder number) fluoresce teal.
    private func stamp(_ text: String, dim: Bool) -> some View {
        let color: Color = isUV
            ? (dim ? Color.paper.opacity(0.3) : Color.stampTeal)
            : Color.text
        return Text(text)
            .font(Typography.timestamp)
            .tracking(Typography.stampTracking)
            .foregroundStyle(color)
            .glow(isUV && !dim ? Color.stampTeal : .clear)
    }

    private var mrzBand: some View {
        ZStack(alignment: .leading) {
            Rectangle().fill(isUV ? Color.paper.opacity(0.03) : Color.text.opacity(0.04))
            Text(PassportHolder.mrz(name: user.displayName))
                .font(Typography.passportCoord)
                .tracking(1.5)
                .foregroundStyle(isUV ? Color.stampTeal : Color.text.opacity(0.4))
                .glow(isUV ? Color.stampTeal : .clear)
                .lineLimit(1)
                .padding(.leading, 14)
        }
        .frame(width: 232, height: 20)
        .overlay(alignment: .top) {
            Rectangle()
                .fill(isUV ? Color.stampTeal.opacity(0.3) : Color.text.opacity(0.12))
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

/// A soft fluorescing halo for text/shapes that glow after dark. `.clear`
/// disables it (daylight), so call sites read declaratively.
private extension View {
    func glow(_ color: Color) -> some View {
        shadow(color: color == .clear ? .clear : color.opacity(0.8),
               radius: color == .clear ? 0 : 4)
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
