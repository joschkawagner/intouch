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
//  ⚠️ NOT YET VERIFIED — nothing renders this. Everything about the ID card
//  except its terrain density is unverified until it is wired into ProfileView.
//
//  ⚠️ THREE OPEN QUESTIONS, marked UNRESOLVED below and at their sites. They are
//  one question in three places — does this read as DELIBERATE or as a FAILURE?
//  That ambiguity is what security printing is, which is why they must be judged
//  together on screen and not settled one at a time by argument:
//    1. OVD patch clearance against the name row (8pt).
//    2. Ghost initials placement and weight.
//    3. The empty col-B row 3.
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

            // UNRESOLVED (3): col B row 3 is deliberately EMPTY — printed field
            // space, as the reference leaves. Whether it reads as composed or
            // as "a field failed to load" is a seeing question. Do not fill it
            // to be safe; that decision is pending judgment.

            IDCardField(label: "bio", width: 300) {
                Text(user.bio)
                    .font(Typography.idCardRemarks)
                    .foregroundStyle(isUV ? Color.uvFieldValue : Color.text)
                    .uvFieldLit(isUV)
                    .lineLimit(2)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .referenceOrigin(x: colA, y: 278)
        }
    }
}
