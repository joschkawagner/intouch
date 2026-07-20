//
//  Typography.swift
//  InTouch
//
//  The type scale. Placeholders built on system fonts — we'll swap in real
//  faces later (a condensed grotesque or typewriter mono for stamps, a quiet
//  serif for body). See docs/DESIGN.md § Typography.
//
//  This is the ONLY file allowed to contain a raw font size.
//
//  Note on the UIFont pairs: stamp text is drawn character-by-character around
//  a circle (see ArcText), and measuring a character requires a UIFont. So the
//  stamp fonts are declared as UIFont first and the SwiftUI Font is derived
//  from it — that way the font we measure can never drift from the font we draw.
//

import SwiftUI
import UIKit

enum Typography {

    // MARK: - Stamps
    //
    // Real passport stamps are mechanical type: monospaced, letterspaced,
    // slightly imperfect. Never a friendly rounded sans.

    /// City name arcing along the top edge of a stamp.
    static let stampCityUIFont = UIFont.monospacedSystemFont(ofSize: 13, weight: .bold)
    static var stampCity: Font { Font(stampCityUIFont) }

    /// The date across the middle of a stamp.
    static let stampDateUIFont = UIFont.monospacedSystemFont(ofSize: 15, weight: .semibold)
    static var stampDate: Font { Font(stampDateUIFont) }

    /// The small mark below the date.
    static let stampMarkUIFont = UIFont.monospacedSystemFont(ofSize: 8, weight: .medium)
    static var stampMark: Font { Font(stampMarkUIFont) }

    /// Letterspacing applied to stamp text, in points.
    static let stampTracking: CGFloat = 1.6

    // MARK: - Screen furniture

    /// Big in-page screen title. Condensed width reads as mechanical, not friendly.
    static var masthead: Font {
        Font(UIFont.systemFont(ofSize: 30, weight: .bold, width: .condensed))
    }

    /// Small letterspaced label above or below a masthead.
    static var label: Font {
        Font(UIFont.monospacedSystemFont(ofSize: 11, weight: .medium))
    }

    /// Mechanical timestamp on a feed card.
    static var timestamp: Font {
        Font(UIFont.monospacedSystemFont(ofSize: 11, weight: .regular))
    }

    /// Tab bar item title. UIFont because UITabBarAppearance is a UIKit API.
    static let tabLabelUIFont = UIFont.monospacedSystemFont(ofSize: 10, weight: .medium)

    // MARK: - Reading

    /// Body copy and captions. System serif (New York) — quiet, not geometric.
    static var body: Font { .system(size: 16, design: .serif) }

    /// Secondary body copy, e.g. empty-state explanations.
    static var bodySmall: Font { .system(size: 14, design: .serif) }

    /// Headline inside an empty state.
    static var emptyTitle: Font {
        Font(UIFont.systemFont(ofSize: 20, weight: .semibold, width: .condensed))
    }
}
