//
//  IDCardFront.swift
//  InTouch
//
//  The card's face — everything the holder's ID actually says, composed on the
//  539×340 reference with each element pinned to its design coordinate.
//
//  FRONT ONLY. There is no back. A passport is a booklet you leaf through; an
//  ID is a single face you hold up. Adding a reverse would be inventing a
//  surface with nothing to put on it.
//
//  WHAT IS DELIBERATELY ABSENT:
//    • No friend count, and no slot that could grow one. A number attached to a
//      person is comparable between people, which makes it a scoreboard — the
//      mechanic docs/PRD.md § 4.1 rejects. CITIES counts places, which is why
//      it survives. See DECISIONS.md 2026-07-25.
//    • No photographs, no map, no city pages. Those are the passport. An ID is
//      identity; the book is the record.
//
//  THE HERO RULE holds exactly as in the book: the NAME is the card's one
//  fluorescing element after dark (stampViolet + halo). Every other value is
//  calm at uvFieldValue, every label at uvFieldLabel. The machine strip belongs
//  to the printing layer, not the field system, so it fluoresces independently
//  in stampRed. One hero, no exceptions.
//
//  ✅ RENDERED AND SEEN as of f09c2eb — the card is wired into ProfileView and
//  has run in the simulator in both lighting modes. ⚠️ What that does NOT cover:
//    • ROUTE STABILITY of the card's own render is UNESTABLISHED. Tap ordering
//      selects between stable render outcomes elsewhere in this app and the
//      cause is unknown (DECISIONS.md 2026-07-25). The card is reached by a
//      brand-new path and has not been captured by two routes and compared.
//    • NO BASELINE EXISTS. The status bar is still in frame, so the card's
//      full-frame hash changes every minute by construction.
//    • MICROPRINT DENSITY is container-dependent — see IDCardPrinting.
//
//  THE THREE OPEN QUESTIONS — they were one question in three places (does this
//  read as DELIBERATE or as a FAILURE?), judged together on screen rather than
//  settled one at a time by argument. Two are closed:
//    1. OVD patch clearance against the name row — RESOLVED, but on a NARROWER
//       account than first argued. The claim "8pt reads as registration, not
//       collision" was never tested; what is actually true is that the patch is
//       top-RIGHT and the NAME label mid-LEFT, so they never approach and the
//       clearance is MOOT. Do not reuse 8pt elsewhere on this row's authority.
//    2. Ghost initials placement and weight — RESOLVED. Reads as a second
//       impression beside the plate, not as a stray layer.
//    3. The empty col-B row 3 — RESOLVED 2026-07-26, judged on screen in both
//       modes: it reads as printed field space because the contour printing
//       runs continuously through it. It reads BETTER under UV, not worse —
//       the prediction went the other way, which is why this was a seeing
//       question and not one to settle by argument.
//
//  Q4 (bio wrap) WAS TESTED 2026-07-26 with a temporary long-bio substitution
//  and the verdict split: the two-line wrap and the ellipsis were right, but
//  SwiftUI's tail truncation cut MID-WORD ("…than dow…"), which reads as
//  software counting characters where a document breaks at the field's width.
//  Fixed by `machinePrinted(_:)` below — the bio is line-broken the way the
//  personalising machine would break it, and the Text's lineLimit(2) is now a
//  safety net that never engages mid-word.
//

import SwiftUI

struct IDCardFront: View {

    let user: UserProfile

    @Environment(\.passportRenderMode) private var mode
    private var isUV: Bool { mode.isUV }

    // Column geometry. Plate 0–180, gutter to 200, then two field columns.
    private let colA: CGFloat = 200
    private let colB: CGFloat = 372
    private let colAWidth: CGFloat = 160
    private let colBWidth: CGFloat = 145
    private let fullWidth: CGFloat = 317   // colA → 517, the card's right margin

    var body: some View {
        IDCardFace(seed: "id-card/\(user.id)") {
            ZStack(alignment: .topLeading) {

                // ── Ghost portrait: a second, smaller impression BESIDE the
                // plate, in the band between the header rule (y=48) and the
                // name label (y=128). Adjacency is its security function — it
                // is compared against the primary by being seen next to it.
                // It clears the field block entirely, which is what the
                // card-spanning first version did not.
                IDCardGhostInitials(initials: user.initials)
                    .referenceOrigin(x: 200, y: 54)

                IDCardOVDPatch()
                    .referenceOrigin(x: 452, y: 56)

                header

                IDCardPortraitPlate(initials: user.initials)
                    .referenceOrigin(x: 0, y: 62)

                IDCardMachineStrip(name: user.displayName)
                    .referenceOrigin(x: 0, y: 294)

                fields
            }
        }
    }

    // MARK: - Header band

    private var header: some View {
        ZStack(alignment: .topLeading) {
            Text("INTOUCH · IDENTITY CARD")
                .font(Typography.idCardTitle)
                .tracking(Typography.idCardTitleTracking)
                // Black offset ink does not fluoresce; personalisation and
                // security inks do. So the title is dominant by day and RECEDES
                // to the label floor after dark — which is also what keeps the
                // field-glow rule intact by refusing a second hero.
                .foregroundStyle(isUV ? Color.uvFieldLabel : Color.ink)
                .uvFieldLit(isUV)
                .referenceOrigin(x: 22, y: 16)

            Text("HOLDER NO.")
                .font(Typography.idCardLabel)
                .tracking(Typography.idCardLabelTracking)
                .foregroundStyle(isUV ? Color.uvFieldLabel : Color.text.opacity(0.5))
                .uvFieldLit(isUV)
                .frame(width: 200, alignment: .trailing)
                .referenceOrigin(x: 317, y: 12)

            Text(PassportHolder.formattedNumber)
                .font(Typography.idCardSerial)
                .foregroundStyle(isUV ? Color.uvFieldValue : Color.text)
                .uvFieldLit(isUV)
                .frame(width: 200, alignment: .trailing)
                .referenceOrigin(x: 317, y: 24)

            // Full-bleed rule under the header — the document naming itself,
            // then a line, then the data. Deliberately NO microprint row here:
            // IDCardPrinting already runs microprint along two edges, and the
            // book's round 3 learned that four subordinate systems at once
            // shout over the terrain.
            Rectangle()
                .fill(mode.printedInk(uv: .stampRed, uvOpacity: 0.30, day: 0.06))
                .frame(width: IDCardMetrics.referenceSize.width, height: 1)
                .referenceOrigin(x: 0, y: 48)
        }
    }

    // MARK: - Fields

    private var fields: some View {
        ZStack(alignment: .topLeading) {
            // The card's ONE hero.
            IDCardField(label: "name", width: fullWidth) {
                Text(user.displayName)
                    .font(Typography.idCardName)
                    .foregroundStyle(isUV ? Color.stampViolet : Color.ink)
                    .fluoresce(isUV ? Color.stampViolet : .clear)
                    .lineLimit(1)
                    .minimumScaleFactor(0.75)
            }
            .referenceOrigin(x: colA, y: 128)

            IDCardField(label: "handle", width: colAWidth) {
                IDCardValue(text: Typography.chrome(user.handle))
            }
            .referenceOrigin(x: colA, y: 184)

            IDCardField(label: "member since", width: colBWidth) {
                IDCardValue(text: DocumentDate.monthYear(user.joinedDate))
            }
            .referenceOrigin(x: colB, y: 184)

            // Zero-padded so it reads as a document field rather than a score —
            // the same instinct as the %04d in PassportHolder.mrz.
            IDCardField(label: "cities", width: colAWidth) {
                IDCardValue(text: String(format: "%02d", user.cityCount))
            }
            .referenceOrigin(x: colA, y: 231)

            // Col B row 3 is deliberately EMPTY — printed field space, as the
            // reference leaves it. RESOLVED 2026-07-26 (was open question 3):
            // judged on screen in both modes, it reads as composed, and better
            // under UV than by day — the terrain running continuously through
            // the gap is what carries it. Do not fill it.

            IDCardField(label: "bio", width: 300) {
                Text(machinePrinted(user.bio))
                    .font(Typography.idCardRemarks)
                    .foregroundStyle(isUV ? Color.uvFieldValue : Color.text)
                    .uvFieldLit(isUV)
                    .lineLimit(2)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .referenceOrigin(x: colA, y: 278)
        }
    }

    // MARK: - Machine line-breaking

    /// The bio broken the way the MACHINE that personalised the card would
    /// break it: a fixed column budget per line, words never split.
    ///
    /// Courier advances exactly 0.6em per glyph, so at idCardRemarks' 12pt a
    /// column is 7.2pt and 41 columns fill 295.2pt of the field's 300 —
    /// character counting IS width measurement on a monospace face. When the
    /// text overruns the last line it is cut back to the last whole word that
    /// leaves a column for the ellipsis: a mid-word "…than dow…" reads as
    /// software counting characters, where a document breaks at the field's
    /// width (Q4's verdict, 2026-07-26). A single word wider than the field is
    /// hard-cut — that is not prose, and a field cannot grow for it.
    private func machinePrinted(_ text: String) -> String {
        let columns = 41   // 300pt field / 7.2pt per Courier-12 column
        let maxLines = 2

        var lines: [String] = []
        var current = ""
        var truncated = false

        for word in text.split(separator: " ").map(String.init) {
            let candidate = current.isEmpty ? word : current + " " + word
            if candidate.count <= columns {
                current = candidate
            } else if current.isEmpty {
                current = String(word.prefix(columns))
            } else if lines.count + 1 < maxLines {
                lines.append(current)
                current = String(word.prefix(columns))
            } else {
                truncated = true
                break
            }
        }
        lines.append(current)

        if truncated {
            var last = lines.removeLast()
            // Make room for the ellipsis without ever splitting a word: drop
            // whole trailing words until it fits; hard-cut only if a single
            // word still overflows on its own.
            while last.count + 1 > columns {
                if let cut = last.range(of: " ", options: .backwards) {
                    last = String(last[..<cut.lowerBound])
                } else {
                    last = String(last.prefix(columns - 1))
                }
            }
            lines.append(last + "…")
        }
        return lines.joined(separator: "\n")
    }
}
