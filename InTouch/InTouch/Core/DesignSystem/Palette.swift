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

// MARK: - UV / after-dark inks

extension Color {

    /// The passport's after-dark ground. Under UV the whole booklet drops onto
    /// this near-black violet-ink field, and the fenced `stamp*` inks (violet /
    /// teal / cobalt) fluoresce against it. Distinct from the muted eight tokens
    /// (which own daylight chrome) — these exist only for the passport's UV state
    /// (see docs/DESIGN.md § the passport booklet, the blacklight/night pass).
    static let uvGround = Color(hex: 0x0D0714)

    /// Fill for a photo / placeholder collage cell under UV. Photographs can't
    /// fluoresce, so photo cells go dark and non-reactive on this dim violet
    /// while the grid lines and outlined empty cells glow around them.
    static let uvCell = Color(hex: 0x150A20)

    /// Bright fluorescing violet used for hero text under UV (e.g. the colophon's
    /// strongest hidden reveal). The glow itself is `stampViolet` shadow behind it.
    static let uvVioletText = Color(hex: 0xF3E9FB)

    /// THE FIELD-GLOW RULE (UV). One system, no per-field exceptions:
    /// ALL field labels render `uvFieldLabel`; ALL field values render
    /// `uvFieldValue`; each page gets AT MOST ONE content hero that fluoresces
    /// (a `stamp*` ink + `.fluoresce()` halo) — identity: the name + photo
    /// block; city page: the masthead; colophon: none (the heavy security
    /// printing is its drama). The MRZ band belongs to the machine/printing
    /// layer, not the field system, so it fluoresces independently. The
    /// printing layer carries the page's fluorescence; the data stays calm.
    /// Glow is lighting, not geometry — both modes render identical elements.
    ///
    /// Legibility floor for non-glowing text under UV. `paper` at this opacity
    /// clears ~5.3:1 contrast on `uvGround` (WCAG AA body text is 4.5:1) — the
    /// minimum a routine field may use and still read. Small struck field labels
    /// sit here; recede *values* sit a step above (`uvFieldValue`). The glowing
    /// hero fields use the saturated `stamp*` inks + a `.fluoresce()` halo — a
    /// separate visual channel (hue + glow), so they stay clearly more prominent
    /// however bright this neutral recede text is.
    static let uvFieldLabel = Color.paper.opacity(0.5)

    /// A recede (non-glowing) field *value* under UV — routine content such as
    /// handle, since, bio, member-since, holder no., city date. One step above
    /// the label floor (~6:1) so content reads stronger than its label, mirroring
    /// the daylight hierarchy where the value outweighs its 0.5-opacity label.
    static let uvFieldValue = Color.paper.opacity(0.6)
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
