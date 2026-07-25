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

#Preview {
    PassportColophonPage(user: MockData.currentUser, cityCount: 7, photoCount: 29)
        .frame(width: 232, height: 330)
        .padding()
        .background(Color.muted)
}
