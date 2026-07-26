//
//  Typography.swift
//  InTouch
//
//  The type system. Two faces, on purpose (see docs/DESIGN.md § Typography):
//
//    • Display  → Jost, bundled (Resources/Fonts, OFL). Cold, geometric,
//      Bauhaus. Everything the interface says — mastheads, nav, labels, body.
//    • Stamps   → Courier, ships with iOS. Real passport stamps are struck by a
//      machine, not set in a designed typeface; Courier is what makes a stamp,
//      date or timestamp read as an artifact rather than a graphic.
//
//  This is the ONLY file allowed to contain a raw font size.
//
//  The display face is declared as a SINGLE constant (`displayFace`) that every
//  UI style derives from, so trialling another cold geometric face later —
//  Futura, say — is a one-line change. The PostScript names are confirmed at
//  runtime by FontAudit, not assumed.
//
//  The Courier "machine type" is kept UIFont-first with the SwiftUI Font derived
//  from it, so a view that needs to measure a glyph gets exactly the drawn font.
//  Some of these tokens are parked for the rebuilt passport booklet (see
//  docs/DECISIONS.md — procedural stamps removed); the marks and letterspacing
//  are used app-wide as machine type in mastheads, Connect and Profile.
//

import SwiftUI
import UIKit

enum Typography {

    // MARK: - Display face (the one thing you change to swap the whole UI face)

    /// PostScript-name stem of the bundled display family. Weights are
    /// `\(displayFace)-Regular/-SemiBold/-Bold`, confirmed by FontAudit at launch.
    /// Swap this (and, if the new face names its weights differently, the
    /// `Weight.suffix` values) to trial another face.
    static let displayFace = "Jost"

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
    ///
    /// Pass `relativeTo:` and the type scales with the user's Dynamic Type setting,
    /// anchored to that text style — this is what every on-screen UI token does.
    /// Omit it and the size is fixed: that path is *only* for type baked into a
    /// fixed-size graphic (avatar initials in a fixed circle, a collage badge sized
    /// as a fraction of the collage width). Those must not scale independently of
    /// their container or they break its layout — do not add `relativeTo:` there.
    static func display(_ size: CGFloat, _ weight: Weight = .regular,
                        relativeTo textStyle: Font.TextStyle? = nil) -> Font {
        let name = "\(displayFace)-\(weight.suffix)"
        if let textStyle {
            return .custom(name, size: size, relativeTo: textStyle)
        }
        return .custom(name, size: size)
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

    // MARK: - Screen furniture (Jost)

    /// Big in-page screen title.
    static var masthead: Font { display(34, .bold, relativeTo: .largeTitle) }

    /// Small letterspaced detail line above a masthead, or a footnote in the voice.
    /// Was 13pt for Josefin's small x-height; Jost carries more presence, so tightened.
    static var label: Font { display(12, .semiBold, relativeTo: .caption) }

    /// Headline inside an empty state.
    static var emptyTitle: Font { display(23, .semiBold, relativeTo: .title2) }

    /// Tab-bar item title. UIFont because `UITabBarAppearance` is a UIKit API.
    /// Deliberately fixed: iOS tab bars don't grow their labels inline at
    /// accessibility text sizes — they expose the large-content-viewer HUD (a
    /// long-press magnified overlay) instead. Scaling this via UIFontMetrics would
    /// only risk clipping the label in the fixed-height bar for no real gain.
    static let tabLabelUIFont = displayUIFont(11, .semiBold)

    /// The big number in a profile stat (cities — never a count of people).
    static var statNumber: Font { display(26, .bold, relativeTo: .title) }

    // MARK: - Reading (Jost)

    /// Body copy and captions. Was 17.5 to compensate for Josefin's small x-height;
    /// Jost sits larger on the body, so tightened back toward the base 16.
    static var body: Font { display(16.5, relativeTo: .body) }

    /// Secondary body copy, e.g. empty-state explanations.
    static var bodySmall: Font { display(15.5, relativeTo: .subheadline) }

    // MARK: - Stamps, dates, timestamps (Courier — machine type)

    // The stamp fonts below are deliberately FIXED (no Dynamic Type): they get
    // baked into fixed-size graphics — the mark inside EmptyStateView's 118pt ghost
    // ring, and the passport booklet when it's rebuilt — where the type is a
    // fraction of a fixed shape. Scaling them independently would burst the layout,
    // so leave them fixed. (The timestamp below is different: it is a free-flowing
    // caption line, not baked into a graphic, so it does scale.)
    //
    // `stampCity` / `stampDate` are unused this phase — parked for the rebuilt
    // passport (procedural stamps removed; see docs/DECISIONS.md).

    /// City name arcing along the top edge of a stamp. Parked for the passport rebuild.
    static let stampCityUIFont = courier(13, bold: true)
    static var stampCity: Font { Font(stampCityUIFont) }

    /// The date across the middle of a stamp. Parked for the passport rebuild.
    static let stampDateUIFont = courier(15, bold: true)
    static var stampDate: Font { Font(stampDateUIFont) }

    /// The small mark below the date. Bumped from 8 — Courier is light at tiny sizes.
    static let stampMarkUIFont = courier(9, bold: false)
    static var stampMark: Font { Font(stampMarkUIFont) }

    /// Letterspacing applied to stamp text, in points.
    static let stampTracking: CGFloat = 1.6

    /// Letterspacing for a machine-set METADATA line — a timestamp kicker, a coordinate
    /// readout, a microprint band. Lighter than `stampTracking`, because a struck mark wants
    /// air around every glyph while a data line only wants to read as machine-set rather than
    /// typeset. Named for the role, not the caller: the same value serves `timestamp`,
    /// `passportCoord` and `passportMicroprint`, so the passport's sites can adopt it without
    /// a rename when they migrate (they are inside the pixel gate; see docs/BASELINES.md).
    static let machineTracking: CGFloat = 1

    /// Mechanical timestamp on a feed card / calendar row. Unlike the stamp fonts
    /// this is a normal caption line, so it scales with Dynamic Type. `.custom`
    /// falls back to the system face on its own if Courier is ever missing.
    static var timestamp: Font { .custom("Courier", size: 11, relativeTo: .caption2) }

    // MARK: - Passport booklet (fixed sizes — baked into the scaled page)

    // The passport pages are authored on a fixed 232×330 reference and scaled to
    // fit the device page (see PassportPage), so their type is baked into a
    // fixed-size graphic exactly like the stamp fonts above — deliberately no
    // Dynamic Type. Sizes come straight from the design (Passport Cover
    // Directions): scaling with the page is correct; scaling independently would
    // burst the reference layout. City names reuse `masthead`; dates/holder-no
    // reuse `timestamp`; letterspacing reuses `stampTracking`.

    /// The "passport" wordmark on the cover.
    static var passportWordmark: Font { display(24, .bold) }

    /// A holder field value on the open identity spread (e.g. the name).
    static var passportName: Font { display(14, .bold) }

    /// The holder initials struck into the identity page's photo block.
    static var passportAvatarInitials: Font { display(30, .bold) }

    /// A field's body value on a passport page (e.g. the bio line).
    static var passportBody: Font { display(13) }

    /// A small letterspaced field label on a passport page ("name", "since").
    static var passportLabel: Font { display(12, .semiBold) }

    /// Machine-type coordinate line under a city label ("47.3769°N · 8.5417°E").
    static var passportCoord: Font { Font(courier(8, bold: false)) }

    /// The vertical microprint band running up the page gutter ("INTOUCH · …").
    static var passportMicroprint: Font { Font(courier(4, bold: false)) }

    // MARK: - ID card (fixed sizes — baked into the scaled card)

    // The ID card is authored on its own fixed 539×340 reference (ID-1, 85.6×54mm
    // — see IDCardMetrics) and scaled to fit, exactly as the passport page is on
    // its ID-3 232×330. Same rule, different geometry: no Dynamic Type, because
    // the type is baked into a fixed-size graphic and scaling it independently
    // would burst the layout.
    //
    // THE REGISTER IS INVERTED FROM THE PASSPORT PAGE, deliberately. On a page,
    // labels and values sit at nearly the same size and the name is set in Jost.
    // On a card every VALUE is Courier and every LABEL is Jost, with the value
    // roughly twice the label — a page is printed and filled in; a card is
    // personalised by a machine. That inversion is the single strongest reason
    // the card reads as a different object rather than a page turned sideways.

    /// The card's own masthead — "INTOUCH · IDENTITY CARD", widest tracking in the app.
    static var idCardTitle: Font { display(15, .semiBold) }
    /// Letterspacing for `idCardTitle`. Wider than `stampTracking`: a document
    /// naming itself across its top edge, not a struck mark.
    static let idCardTitleTracking: CGFloat = 4.5

    /// A struck field label on the card ("NAME", "CITIES"). Small and Jost —
    /// half the size of the value it sits above.
    static var idCardLabel: Font { display(9.5, .semiBold) }
    /// Letterspacing for `idCardLabel`.
    static let idCardLabelTracking: CGFloat = 1.2

    /// The holder's name — the card's one fluorescing hero.
    static var idCardName: Font { Font(courier(26, bold: true)) }
    /// The document number in the header band.
    static var idCardSerial: Font { Font(courier(15, bold: true)) }
    /// An ordinary machine-set field value (handle, member since, cities).
    static var idCardValue: Font { Font(courier(17, bold: false)) }
    /// The bio / remarks line — the one value allowed to wrap.
    static var idCardRemarks: Font { Font(courier(12, bold: false)) }

    /// Letterspacing for the card's machine-readable strip. A token rather than
    /// a literal at the call site: the passport's MRZ hardcodes `.tracking(1.5)`
    /// and is logged as a design-system violation to fix — no reason to add a
    /// second instance of the same mistake.
    static let idCardMrzTracking: CGFloat = 1.5

    /// Holder initials struck into the portrait plate.
    static var idCardInitials: Font { display(72, .bold) }
    /// Initials inside the ghost portrait — the small second impression beside
    /// the plate. Sized against the PLATE's initials (72 in a 180-wide plate),
    /// scaled to the ghost's 44-wide block. Was 190 when this was mistakenly a
    /// card-spanning watermark; a ghost is adjacent and comparable, not vast.
    static var idCardGhost: Font { display(18, .bold) }

    // MARK: - Collage content (a hand, not chrome)

    /// Handwritten-style face for collage `.text` scraps. This is *content*, not
    /// interface, so a third face is fine here where it never is in the chrome.
    /// Parametric: CollageView passes a size proportional to the collage width so
    /// the scrap stays the same relative size on every device. The face lives here;
    /// only the (relative) size is computed at the call site.
    ///
    /// Deliberately FIXED (no Dynamic Type): the size is already a fraction of the
    /// collage width, so it scales with the collage. Layering Dynamic Type on top
    /// would break the scrap out of the composition — leave it as-is.
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
