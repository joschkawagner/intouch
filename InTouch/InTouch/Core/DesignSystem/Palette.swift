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
    /// The register's home today is the passport's UV state: the security printing
    /// and the per-page hero fields fluoresce in these inks after dark (daylight
    /// stamps still ship muted — person → ink, event → live, first city → night).
    ///
    /// STRICTLY for **stamps, marks, and the UV fluorescence** — the struck ink of a
    /// passport stamp. Never use them for paper, body text, or chrome; the muted
    /// eight-token palette above owns all of that and must stay muted (see
    /// docs/DESIGN.md § Palette). Chosen by eye in the passport-stamp register; no
    /// source chips, so treat as tunable. Brightened for the UV pass: the original
    /// print-dark hexes barely registered on `uvGround` — these sit in the
    /// fluorescing register the reference photographs show, and today they render
    /// only after dark, so daylight is untouched.
    static let stampRed    = Color(hex: 0xE04A38)   // bright cinnabar — the classic stamp red
    static let stampTeal   = Color(hex: 0x17A9A6)
    static let stampViolet = Color(hex: 0x8B44C8)
    static let stampForest = Color(hex: 0x2E9E55)
    static let stampCobalt = Color(hex: 0x3568C9)
    static let stampGold   = Color(hex: 0xD9AE31)   // ink-gold — registration marks, microprint
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

    /// Cool violet-white — the tone of paper lit by blacklight. The basis of
    /// the uniform UV field treatment below: neutral `paper` white read as
    /// ordinary unlit text sitting on top of the scene, where this cast reads
    /// as the same text under the same lamp.
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
    /// Legibility floor for non-glowing text under UV. `uvVioletText` at this
    /// opacity clears ~5:1 contrast on `uvGround` (WCAG AA body text is 4.5:1)
    /// — the minimum a routine field may use and still read. Small struck
    /// field labels sit here; recede *values* sit a step above
    /// (`uvFieldValue`). The cool cast (not neutral `paper`) makes the calm
    /// text read as lit by the same blacklight as the artwork. The glowing
    /// hero fields use the saturated `stamp*` inks + a `.fluoresce()` halo — a
    /// separate visual channel (hue + glow), so they stay clearly more
    /// prominent however bright this recede text is.
    static let uvFieldLabel = Color.uvVioletText.opacity(0.5)

    /// A recede (non-glowing) field *value* under UV — routine content such as
    /// handle, since, bio, member-since, holder no., city date. One step above
    /// the label floor (~6:1) so content reads stronger than its label, mirroring
    /// the daylight hierarchy where the value outweighs its 0.5-opacity label.
    static let uvFieldValue = Color.uvVioletText.opacity(0.62)
}

// MARK: - Bauhaus collage frames

extension Color {

    /// The Bauhaus register, sampled by eye from the reference poster
    /// (docs/references — bauhaus-background.jpg): cerulean blue, golden
    /// yellow, burnt brick red, warm grid black, and the cream ground.
    /// Deliberately NOT the fire-engine primaries the deleted first-pass
    /// tokens guessed — the reference is warmer and dirtier throughout.
    ///
    /// STRICTLY for the passport collage photo frames (daylight). Never
    /// chrome, never text; the muted eight own those. A wider Bauhaus
    /// treatment of the app is a separate future exploration — this fenced
    /// group is the seed of that register, so keep it faithful to the
    /// reference rather than convenient for any one screen.
    static let bauhausBlue   = Color(hex: 0x1B7ABF)
    static let bauhausYellow = Color(hex: 0xEDB41F)
    static let bauhausRed    = Color(hex: 0xA93A20)
    static let bauhausBlack  = Color(hex: 0x221A12)
    static let bauhausCream  = Color(hex: 0xEFE3CC)

    /// Frame colours in a fixed order — a collage page hashes into this.
    static let bauhausFrames: [Color] = [bauhausBlue, bauhausYellow, bauhausRed, bauhausBlack]
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
