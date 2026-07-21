//
//  Typography.swift
//  InTouch
//
//  The type system. Two faces, on purpose (see docs/DESIGN.md § Typography):
//
//    • Display  → Josefin Sans, bundled (Resources/Fonts, OFL). Cold, geometric,
//      Bauhaus. Everything the interface says — mastheads, nav, labels, body.
//    • Stamps   → Courier, ships with iOS. Real passport stamps are struck by a
//      machine, not set in a designed typeface; Courier is what makes a stamp,
//      date or timestamp read as an artifact rather than a graphic.
//
//  This is the ONLY file allowed to contain a raw font size.
//
//  The display face is declared as a SINGLE constant (`displayFace`) that every
//  UI style derives from, so trialling another cold geometric face later —
//  Jost*, Futura — is a one-line change. The PostScript names are confirmed at
//  runtime by FontAudit, not assumed.
//
//  Stamp fonts stay UIFont-first with the SwiftUI Font derived from them, because
//  ArcText lays the city name out glyph by glyph and measuring a glyph needs a
//  UIFont (see ArcText). Deriving one from the other means the measured font can
//  never drift from the drawn font.
//

import SwiftUI
import UIKit

enum Typography {

    // MARK: - Display face (the one thing you change to swap the whole UI face)

    /// PostScript-name stem of the bundled display family. Weights are
    /// `\(displayFace)-Regular/-SemiBold/-Bold`, confirmed by FontAudit at launch.
    /// Swap this (and, if the new face names its weights differently, the
    /// `Weight.suffix` values) to trial another face.
    static let displayFace = "JosefinSans"

    enum Weight {
        case regular, semiBold, bold

        var suffix: String {
            switch self {
            case .regular: "Regular"
            case .semiBold: "SemiBold"
            case .bold: "Bold"
            }
        }

        /// System fallback weight, used only if the bundled face fails to load.
        var uiWeight: UIFont.Weight {
            switch self {
            case .regular: .regular
            case .semiBold: .semibold
            case .bold: .bold
            }
        }
    }

    /// A SwiftUI display style at `size`/`weight`. All UI type routes through here.
    static func display(_ size: CGFloat, _ weight: Weight = .regular) -> Font {
        .custom("\(displayFace)-\(weight.suffix)", size: size)
    }

    /// The UIKit twin, for the one place UIKit needs it: the tab-bar label
    /// (`UITabBarAppearance`). Falls back to the system face if the font is missing
    /// rather than force-unwrapping.
    static func displayUIFont(_ size: CGFloat, _ weight: Weight = .regular) -> UIFont {
        UIFont(name: "\(displayFace)-\(weight.suffix)", size: size)
            ?? .systemFont(ofSize: size, weight: weight.uiWeight)
    }

    // MARK: - Lowercase chrome (Bauhaus)

    /// Herbert Bayer argued capitals were redundant; the Bauhaus alphabet had none.
    /// When true, navigation labels and mastheads render lowercase. Flip to see it
    /// the other way — it is deliberately the only switch that controls chrome case.
    static let lowercaseChrome = true

    /// Applies the chrome-case rule to a label. Use for tab titles and mastheads.
    static func chrome(_ string: String) -> String {
        lowercaseChrome ? string.lowercased() : string
    }

    // MARK: - Screen furniture (Josefin Sans)

    /// Big in-page screen title.
    static var masthead: Font { display(34, .bold) }

    /// Small letterspaced detail line above a masthead, or a footnote in the voice.
    /// Bumped from the old 11pt: Josefin's small x-height needs the extra size.
    static var label: Font { display(13, .semiBold) }

    /// Headline inside an empty state.
    static var emptyTitle: Font { display(23, .semiBold) }

    /// Tab-bar item title. UIFont because `UITabBarAppearance` is a UIKit API.
    static let tabLabelUIFont = displayUIFont(11, .semiBold)

    /// The big number in a profile stat (friend / stamp count).
    static var statNumber: Font { display(26, .bold) }

    // MARK: - Reading (Josefin Sans)

    /// Body copy and captions. Bumped from 16 to compensate for the small x-height.
    static var body: Font { display(17.5) }

    /// Secondary body copy, e.g. empty-state explanations.
    static var bodySmall: Font { display(15.5) }

    // MARK: - Stamps, dates, timestamps (Courier — machine type)

    /// City name arcing along the top edge of a stamp.
    static let stampCityUIFont = courier(13, bold: true)
    static var stampCity: Font { Font(stampCityUIFont) }

    /// The date across the middle of a stamp.
    static let stampDateUIFont = courier(15, bold: true)
    static var stampDate: Font { Font(stampDateUIFont) }

    /// The small mark below the date. Bumped from 8 — Courier is light at tiny sizes.
    static let stampMarkUIFont = courier(9, bold: false)
    static var stampMark: Font { Font(stampMarkUIFont) }

    /// Letterspacing applied to stamp text, in points.
    static let stampTracking: CGFloat = 1.6

    /// Mechanical timestamp on a feed card / calendar row.
    static var timestamp: Font { Font(courier(11, bold: false)) }

    // MARK: - Collage content (a hand, not chrome)

    /// Handwritten-style face for collage `.text` scraps. This is *content*, not
    /// interface, so a third face is fine here where it never is in the chrome.
    /// Parametric: CollageView passes a size proportional to the collage width so
    /// the scrap stays the same relative size on every device. The face lives here;
    /// only the (relative) size is computed at the call site.
    static func collage(_ size: CGFloat) -> Font {
        .custom("BradleyHandITCTT-Bold", size: size)
    }

    // MARK: - Courier helper

    /// Courier ships with iOS in exactly two weights (Regular, Bold). Falls back to
    /// the monospaced system face if — impossibly — it's missing, so no force-unwrap.
    private static func courier(_ size: CGFloat, bold: Bool) -> UIFont {
        UIFont(name: bold ? "Courier-Bold" : "Courier", size: size)
            ?? .monospacedSystemFont(ofSize: size, weight: bold ? .bold : .regular)
    }
}
