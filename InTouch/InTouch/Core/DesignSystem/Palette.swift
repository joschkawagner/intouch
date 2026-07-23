//
//  Palette.swift
//  InTouch
//
//  The eight colour tokens from docs/DESIGN.md.
//
//  This is the ONLY file in the codebase allowed to contain a raw hex value.
//  If you need a colour that isn't here, add it here first, then use the token.
//

import SwiftUI

extension Color {

    /// Primary surface — feeds, passport pages. Coconut Milk.
    static let paper = Color(hex: 0xF0EDE5)

    /// Brand, passport cover, person-stamp ink, primary buttons. Red Inferno.
    static let ink = Color(hex: 0x4E0000)

    /// Immersive dark surface — handshake, live events. Pantone 2965 C.
    static let night = Color(hex: 0x00344E)

    /// Body copy. Warmer than black — never use pure black.
    static let text = Color(hex: 0x594536)

    /// Aged-paper highlight, unread / new indicators. Pastel Yellow.
    static let aged = Color(hex: 0xF2E6B1)

    /// Dividers, inactive states, map land. Reseda.
    static let muted = Color(hex: 0xA1AD92)

    /// Event live indicator, success states. Chive.
    static let live = Color(hex: 0x4A5335)

    /// Map water, links, secondary accent. Powder Blue.
    static let water = Color(hex: 0x94B2C4)
}

// MARK: - Saturated stamp inks

extension Color {

    /// Bright, saturated inks in the register of real passport / immigration stamps —
    /// the kind that pool at the edges and read as *alive*, not tasteful. The shipping
    /// stamp ink (`ink`, #4E0000) is nearly black; these were the brighter alternative.
    ///
    /// CURRENTLY UNUSED: stamps ship muted (person → ink, event → live, first city →
    /// night). These are kept because the brighter register may return; harmless until then.
    ///
    /// STRICTLY for **stamps and marks** — the struck ink of a passport stamp. Never
    /// use them for paper, body text, or chrome; the muted eight-token palette above
    /// owns all of that and must stay muted (see docs/DESIGN.md § Palette). Chosen by
    /// eye in the passport-stamp register; no source chips, so treat as tunable.
    static let stampRed    = Color(hex: 0xC4271F)   // bright cinnabar — the classic stamp red
    static let stampTeal   = Color(hex: 0x0E7C7D)
    static let stampViolet = Color(hex: 0x6B2E9C)
    static let stampForest = Color(hex: 0x1E6B39)
    static let stampCobalt = Color(hex: 0x1E4FA0)
}

// MARK: - Bauhaus city blocks

extension Color {

    /// Solid colour blocks for the passport's per-city pages. Classic Bauhaus
    /// register — flat, primary-leaning, unshaded — so each city reads as one
    /// bold plane while we build the real collage in a later pass.
    ///
    /// A city is mapped to one of these by a stable hash of its name, so a city
    /// always gets the same block. Chosen by eye; treat as tunable. These are
    /// distinct from the muted eight-token palette (chrome + paper) and from the
    /// `stamp*` inks (stamps only) — they exist solely for these full-page blocks.
    static let bauhausRed    = Color(hex: 0xD62828)
    static let bauhausBlue   = Color(hex: 0x1D4E89)
    static let bauhausYellow = Color(hex: 0xE9C46A)
    static let bauhausBlack  = Color(hex: 0x1A1A1A)
    static let bauhausOrange = Color(hex: 0xE07A22)
    static let bauhausTeal   = Color(hex: 0x2A9D8F)
    static let bauhausSand   = Color(hex: 0xD8C3A5)

    /// The city blocks, in a fixed order. A city name hashes into this array.
    static let bauhausBlocks: [Color] = [
        bauhausRed, bauhausBlue, bauhausYellow,
        bauhausBlack, bauhausOrange, bauhausTeal, bauhausSand,
    ]
}

extension Color {

    /// Builds a colour from a 24-bit RGB literal, e.g. `0xF0EDE5`.
    ///
    /// Deliberately `fileprivate`: it exists so the tokens above can be written
    /// as the hex values in DESIGN.md, and nothing outside this file can reach it.
    fileprivate init(hex: UInt32) {
        self.init(
            .sRGB,
            red: Double((hex >> 16) & 0xFF) / 255,
            green: Double((hex >> 8) & 0xFF) / 255,
            blue: Double(hex & 0xFF) / 255,
            opacity: 1
        )
    }
}
