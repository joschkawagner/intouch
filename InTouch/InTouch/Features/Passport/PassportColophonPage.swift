//
//  PassportColophonPage.swift
//  InTouch
//
//  The colophon (design 2d) — the last inside page, carrying the heaviest
//  security printing in the book. It records only what InTouch counts:
//  member-since, cities, and photos, plus the holder number.
//
//  HARD RULE: the colophon shows cities and photos counts and the holder number
//  ONLY. It must never carry a connections / friends / followers figure — not
//  even styled to look official. A public social count is the exact scoreboard
//  InTouch positions against (see docs/PRD.md § Passport, "no vanity metrics").
//
//  Laid out at the 232×330 reference over the `.heavy` security layer, each
//  field pinned to its design coordinate with hairline rules between rows.
//

import SwiftUI

struct PassportColophonPage: View {

    let user: UserProfile
    /// Total cities and photos — the only counts this page carries.
    let cityCount: Int
    let photoCount: Int

    private let rowRules: [CGFloat] = [60, 100, 140, 180, 220]

    var body: some View {
        PassportPage(security: .heavy) {
            ZStack {
                ForEach(rowRules, id: \.self) { y in
                    Rectangle()
                        .fill(Color.text.opacity(0.14))
                        .frame(width: 204, height: 1)
                        .referenceOrigin(x: 14, y: y)
                }

                field(label: "member since", labelY: 68) {
                    stamp(Self.monthYear(user.joinedDate))
                }
                field(label: "cities", labelY: 108) {
                    stat("\(cityCount)")
                }
                field(label: "photos", labelY: 148) {
                    stat("\(photoCount)")
                }
                field(label: "holder no.", labelY: 188) {
                    stamp(PassportHolder.formattedNumber)
                }
            }
        }
    }

    // MARK: - Field pieces

    @ViewBuilder
    private func field<Value: View>(label text: String, labelY: CGFloat,
                                    @ViewBuilder value: () -> Value) -> some View {
        Text(text.uppercased())
            .font(Typography.passportLabel)
            .tracking(Typography.stampTracking)
            .foregroundStyle(Color.text.opacity(0.5))
            .referenceOrigin(x: 14, y: labelY)

        value()
            .referenceOrigin(x: 14, y: labelY + 12)
    }

    /// A machine-type value (Courier) — member since, holder no.
    private func stamp(_ text: String) -> some View {
        Text(text)
            .font(Typography.timestamp)
            .tracking(Typography.stampTracking)
            .foregroundStyle(Color.text)
    }

    /// A count value (display bold) — cities, photos.
    private func stat(_ text: String) -> some View {
        Text(text)
            .font(Typography.passportStat)
            .foregroundStyle(Color.ink)
    }

    private static let formatter: DateFormatter = {
        let f = DateFormatter()
        f.locale = Locale(identifier: "en_US_POSIX")
        f.dateFormat = "MMM yyyy"
        return f
    }()

    private static func monthYear(_ date: Date) -> String {
        formatter.string(from: date).uppercased()
    }
}

#Preview {
    PassportColophonPage(user: MockData.currentUser, cityCount: 7, photoCount: 29)
        .frame(width: 232, height: 330)
        .padding()
        .background(Color.muted)
}
