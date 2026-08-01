//
//  PassportHolder.swift
//  InTouch
//
//  How a holder's serial is PRINTED — on the passport's identity page and
//  colophon, on the ID card's header, and inside both machine-readable bands.
//
//  The number itself is not here. It lives on `UserProfile.passportNumber`,
//  stored, because a serial is issued and recorded rather than computed (the
//  reasoning is written at the declaration). This file is the formatting layer
//  over it: one holder in, one struck string out.
//
//  ⚠️ THE TWO FUNCTIONS BELOW MUST AGREE, AND THIS IS THE FILE THAT SAYS SO.
//  `formattedNumber(for:)` is what a reader sees under `HOLDER NO.`;
//  `mrz(for:)` embeds the same number in the machine zone. On a real document
//  those match, and when they stopped matching here it took three commits and a
//  docs pass to notice — the printed form ran through a quantity formatter and
//  read "1,924" while the MRZ struck "1924" (DECISIONS.md 2026-07-26). They are
//  kept adjacent, in one file, for exactly that reason: splitting them across
//  two types is how they drifted the first time.
//
//  This header used to claim the details were "mocked here, in-feature" and that
//  the build "must not touch anything outside the passport feature". Both were
//  false by the time anyone read them again — the file has lived in Core/Models
//  since `1d2c788` (P2a) and is read by the passport AND the ID card.
//

import Foundation

enum PassportHolder {

    /// The holder number as the machine strikes it: zero-padded to four, and
    /// ungrouped. Serials do not group — the earlier form ran the number through
    /// a quantity formatter and argued carefully about WHICH grouping to use
    /// while never asking WHETHER to group at all.
    static func formattedNumber(for user: UserProfile) -> String {
        String(format: "%04d", user.passportNumber)
    }

    /// The machine-readable band for a holder, e.g.
    /// "JOSCHKA<WAGNER<<INT<1924<<<<…". Padded with filler so it overflows the
    /// band (the band clips it), the way a real MRZ line runs edge to edge.
    ///
    /// The `%04d` here is deliberately the same expression as
    /// `formattedNumber(for:)` above, not a coincidence to be tidied into one —
    /// see the agreement note in this file's header.
    static func mrz(for user: UserProfile) -> String {
        let coded = user.displayName.uppercased()
            .split(separator: " ")
            .joined(separator: "<")
        let core = "\(coded)<<INT<\(String(format: "%04d", user.passportNumber))"
        return core.padding(toLength: max(core.count, 44), withPad: "<", startingAt: 0)
    }
}
