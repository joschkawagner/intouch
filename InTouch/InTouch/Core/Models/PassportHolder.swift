//
//  PassportHolder.swift
//  InTouch
//
//  How a holder is PRINTED — the serial on the passport's identity page and
//  colophon and on the ID card's header, and the whole machine-readable band on
//  both documents, holder name included.
//
//  The band has its own alphabet — `A–Z`, `0–9`, `<`, and nothing else — so the
//  name is transliterated on the way in (see `machineCoded`). That is a second
//  job this file does, and it is here rather than beside the name because the
//  band is the only place the constraint exists.
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

    /// ICAO 9303's expansions, applied BEFORE the diacritic fold below — order
    /// is the whole reason they are separate steps. Fold first and `Ö` becomes
    /// `O`, which is a different policy silently applied.
    ///
    /// ⚠️ ONE ISSUING AUTHORITY, ONE POLICY. ICAO 9303 Part 3 lists BOTH forms
    /// for these letters and lets the issuing state choose: German and Austrian
    /// documents expand (`Ö` → `OE`), Swedish ones strip (`Ö` → `O`). "INT" is
    /// ours, so the choice is ours — and it has to be exactly one, because a
    /// document issuer that transliterated two ways would print two different
    /// machine zones for the same name. Expansion is chosen: it survives being
    /// read back aloud, and it matches the Swiss documents this project's
    /// security printing has been built against throughout.
    ///
    /// NO `ß` ENTRY, and that is verified rather than overlooked: Swift's
    /// `uppercased()` already maps `ß` → `SS` by full Unicode case mapping, so
    /// an entry here would be dead code. Checked by running it, not assumed.
    private static let transliterations: [Character: String] = [
        "Ä": "AE", "Ö": "OE", "Ü": "UE",
        "Å": "AA", "Æ": "AE", "Ø": "OE",
        "Ð": "D",  "Þ": "TH", "Œ": "OE",
    ]

    /// A name reduced to the machine alphabet: `A–Z`, `0–9` and the space that
    /// becomes a `<` separator. Nothing else may reach the band.
    ///
    /// `locale: nil` on the fold is deliberate, the same instinct as
    /// `DocumentDate`'s `en_US_POSIX` pin: a locale-sensitive fold would make a
    /// machine-readable band depend on the reader's device settings, which is
    /// the one place a string must be identical everywhere. Measured, not
    /// assumed — `nil` and `de_DE` agree on the current fixtures.
    ///
    /// KNOWN LIMIT, stated rather than hidden: a name in a non-Latin script has
    /// nothing to fold to and its characters are dropped. That is not a
    /// formatter bug to fix here — a real document carries a separate Latin
    /// transcription field, and this model has one `displayName`. It becomes a
    /// data question when real accounts arrive.
    private static func machineCoded(_ name: String) -> String {
        var expanded = ""
        for character in name.uppercased() {
            expanded.append(transliterations[character] ?? String(character))
        }
        let folded = expanded.folding(options: .diacriticInsensitive, locale: nil)
        return String(folded.map { character in
            (character.isASCII && (character.isLetter || character.isNumber)) || character == " "
                ? character
                : " "
        })
    }

    /// The machine-readable band for a holder, e.g.
    /// "JOSCHKA<WAGNER<<INT<1924<<<<…". Padded with filler so it overflows the
    /// band (the band clips it), the way a real MRZ line runs edge to edge.
    ///
    /// THE NAME IS TRANSLITERATED FIRST. A machine zone is `A–Z`, `0–9` and `<`
    /// — nothing else — and this used to uppercase and join without checking,
    /// so "Juno Bergström" struck `JUNO<BERGSTRÖM<<INT<6127`, a glyph no
    /// machine-readable band on any real document contains. It went unseen
    /// because every other fixture holder is pure ASCII, and because hers is the
    /// one book with no route to it.
    ///
    /// The `%04d` here is deliberately the same expression as
    /// `formattedNumber(for:)` above, not a coincidence to be tidied into one —
    /// see the agreement note in this file's header.
    static func mrz(for user: UserProfile) -> String {
        let coded = machineCoded(user.displayName)
            .split(separator: " ")
            .joined(separator: "<")
        let core = "\(coded)<<INT<\(String(format: "%04d", user.passportNumber))"
        return core.padding(toLength: max(core.count, 44), withPad: "<", startingAt: 0)
    }
}
