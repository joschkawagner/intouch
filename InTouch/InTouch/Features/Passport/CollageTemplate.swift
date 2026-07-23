//
//  CollageTemplate.swift
//  InTouch
//
//  The collage layout system (design 2c): six Mondrian grid templates, one per
//  photo count (1, 2, 3, 4, 5, 6+). Each template is a fixed set of cells in the
//  232×330 reference page; a cell is either a photo cell or an empty cell. Empty
//  cells render outline-only (a hairline ink border, paper showing through) so a
//  1-photo city composes as confidently as a 6-photo one — no solid fills (those
//  are a deferred "try next" in the design; see docs/DECISIONS.md).
//
//  Rects are taken directly from the design in reference points, so they map 1:1
//  when drawn inside a PassportPage.
//

import CoreGraphics

struct CollageCell {
    var rect: CGRect
    var isPhoto: Bool
}

enum CollageTemplate {

    /// The cells for a given photo count, clamped to the 1…6+ templates. Photo
    /// cells come first; any remaining cells are empty (outline-only).
    static func cells(photoCount: Int) -> [CollageCell] {
        switch min(max(photoCount, 1), 6) {
        case 1:
            return [
                photo(0, 0, 143, 330),
                empty(149, 0, 83, 158),
                empty(149, 164, 83, 166),
            ]
        case 2:
            return [
                photo(0, 0, 232, 192),
                photo(0, 198, 151, 132),
                empty(157, 198, 75, 132),
            ]
        case 3:
            return [
                photo(0, 0, 151, 330),
                photo(157, 0, 75, 106),
                photo(157, 112, 75, 106),
                empty(157, 224, 75, 106),
            ]
        case 4:
            return [
                photo(0, 0, 151, 175),
                photo(157, 0, 75, 84),
                photo(157, 90, 75, 85),
                photo(0, 181, 232, 149),
            ]
        case 5:
            return [
                photo(0, 0, 232, 140),
                photo(0, 146, 108, 184),
                photo(114, 146, 55, 88),
                photo(114, 240, 55, 90),
                photo(175, 146, 57, 184),
            ]
        default: // 6+
            return [
                photo(0, 0, 151, 107),
                photo(157, 0, 75, 107),
                photo(0, 113, 75, 217),
                photo(81, 113, 151, 100),
                photo(81, 219, 73, 111),
                photo(160, 219, 72, 111),
            ]
        }
    }

    private static func photo(_ x: CGFloat, _ y: CGFloat, _ w: CGFloat, _ h: CGFloat) -> CollageCell {
        CollageCell(rect: CGRect(x: x, y: y, width: w, height: h), isPhoto: true)
    }

    private static func empty(_ x: CGFloat, _ y: CGFloat, _ w: CGFloat, _ h: CGFloat) -> CollageCell {
        CollageCell(rect: CGRect(x: x, y: y, width: w, height: h), isPhoto: false)
    }
}
