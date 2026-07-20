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
