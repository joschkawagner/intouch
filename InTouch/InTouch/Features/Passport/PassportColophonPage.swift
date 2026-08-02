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

    @Environment(\.passportRenderMode) private var mode
    private var isUV: Bool { mode.isUV }

    private let rowRules: [CGFloat] = [56, 102, 148, 194, 240]

    var body: some View {
        // After dark, the heaviest security printing (frames, rosettes,
        // microprint) is what fluoresces and carries the drama — the counts
        // stay deliberately calm and secondary (they never out-shout the
        // printing). See docs/PRD.md § Passport, "no vanity metrics".
        PassportPage(security: .heavy, seed: "colophon") {
            ZStack {
                ForEach(rowRules, id: \.self) { y in
                    Rectangle()
                        .fill(isUV ? Color.paper.opacity(0.10) : Color.text.opacity(0.14))
                        .frame(width: 204, height: 1)
                        .referenceOrigin(x: 14, y: y)
                }

                field(label: "member since", labelY: 68) {
                    stamp(DocumentDate.monthYear(user.joinedDate))
                }
                field(label: "cities", labelY: 114) {
                    stamp("\(cityCount)")
                }
                field(label: "photos", labelY: 160) {
                    stamp("\(photoCount)")
                }
                field(label: "holder no.", labelY: 206) {
                    stamp(PassportHolder.formattedNumber(for: user))
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
            .foregroundStyle(isUV ? Color.uvFieldLabel : Color.text.opacity(0.5))
            .uvFieldLit(isUV)
            .referenceOrigin(x: 14, y: labelY)

        value()
            .referenceOrigin(x: 14, y: labelY + 16)
    }

    /// Every value on this page — dates, counts, holder number — in the one
    /// machine register (Courier), one size, one colour. The colophon has no
    /// hero (field-glow rule, see Palette.swift): a registry page where the
    /// counts are entries like any other, and the heavy security printing is
    /// the only drama. Emphasising a count again — by hue, weight or size —
    /// would rebuild the scoreboard this page exists to refuse.
    private func stamp(_ text: String) -> some View {
        Text(text)
            .font(Typography.timestamp)
            .tracking(Typography.stampTracking)
            .foregroundStyle(isUV ? Color.uvFieldValue : Color.text)
            .uvFieldLit(isUV)
    }

}

/// ⚠️ THE COUNTS ARE READ FROM THE RECORD, NOT TYPED IN. This preview used to
/// pass the literals `7` and `29` — correct on the day they were written and a
/// second source of truth for the same two numbers, which is precisely the shape
/// `4a3c65b` deleted from `UserProfile.cityCount` and `d5b6ef8` refused for
/// `shortName`. A preview is where such a literal survives longest, because
/// nothing compiles against it being right.
#Preview("Me — 7 cities · 29 photos") {
    PassportColophonPage(user: MockData.currentUser,
                         cityCount: PassportContents.currentUser.cityCount,
                         photoCount: PassportContents.currentUser.totalPhotoCount)
        .frame(width: 232, height: 330)
        .padding()
        .background(Color.muted)
}

/// A friend's colophon — the single page on which a whole derived record is
/// legible: her cities, her photos, her serial, her join month.
///
/// The numbers here are the ones the derivation produces from Nora's two posts
/// (2 cities, 3 photos), NOT the ones the old per-city oracle would have given
/// her (6). Nothing in the running app renders this until the CTA is wired.
#Preview("Nora — a derived record") {
    PassportColophonPage(user: MockData.friendNora,
                         cityCount: PassportContents.nora.cityCount,
                         photoCount: PassportContents.nora.totalPhotoCount)
        .frame(width: 232, height: 330)
        .padding()
        .background(Color.muted)
}
