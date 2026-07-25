//
//  PhotoSlotPolicy.swift
//  InTouch
//
//  How a photo cell behaves against the security printing — shared by every
//  document that has one, currently the passport's city collage and the ID
//  card's portrait plate.
//
//  THE POLICY, not the view. The two documents draw their photo areas very
//  differently: the collage cell is a framed rectangle floating inside a
//  Mondrian grid, the card's plate bleeds off two edges and carries the
//  holder's initials. Only ONE of their five visual aspects matches. What they
//  genuinely share is behaviour:
//
//    1. TRANSLUCENT IN BOTH MODES. The security printing runs continuously
//       beneath the whole document and shows through the slot, dimmed. One
//       object: the printing is on the page, it does not stop where a photo
//       begins. Real passports print security linework straight across the
//       portrait (anti-substitution) — the Swiss UV reference shows contours
//       crossing the photo.
//    2. DARK AND UNLIT AFTER DARK. Photographs do not fluoresce. A photo area
//       sinks under UV, clearly unlit against artwork that IS lit.
//
//  This file exists because those two rules, and the constant below, must not
//  drift between the documents. The views that apply them stay per-document —
//  see the DECISIONS.md correction of 2026-07-25, which records that lifting
//  the passport's photo-slot VIEW into Core was justified on a prediction about
//  the ID card that turned out to be wrong.
//

import SwiftUI

enum PhotoSlotPolicy {

    /// The after-dark fill for a photo cell. Translucent so the printing runs
    /// through it (rule 1), dark so it reads as unlit (rule 2).
    static var uvFill: Color { Color.uvCell.opacity(0.55) }

    /// The dark-wash strength over a REAL photograph after dark, decided in the
    /// UV pass by A/B: 0.35 read as day-lit sky — photos looked LIT; 0.72
    /// swallowed the image; 0.50 is visible, recognisable, obviously not
    /// glowing.
    ///
    /// ⚠️ This is a DECIDED constant, not a tunable default. Do not re-derive it
    /// from a Palette token or demote it to a parameter default without
    /// re-running the A/B.
    ///
    /// ⚠️ It is currently UNUSED — it applies once the photo model lands and
    /// there are real photographs to wash. So **no pixel gate can catch a wrong
    /// value here**: a typo would pass every screenshot comparison silently.
    /// This comment is the only guard until something renders it.
    static let uvPhotoDim: Double = 0.5
}
