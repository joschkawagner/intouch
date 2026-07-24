//
//  CollageTemplate.swift
//  InTouch
//
//  The collage layout system (design 2c): six Mondrian grid templates, one
//  per photo count (1, 2, 3, 4, 5, 6+). Each template is a fixed set of PHOTO
//  cell rects in the 232×330 reference page — every cell holds a photo; there
//  is no empty-cell concept. (This supersedes BOTH earlier calls: solid
//  Bauhaus colour blocks, then outline-only empties — see DECISIONS.md
//  2026-07-24.)
//
//  A city with N photos gets an N-cell template. Sparse cities stay
//  *composed*: the photos occupy a deliberate part of the grid and the rest
//  is bare printed page — the security printing showing through is the
//  composition, not missing content.
//
//  Rects are taken directly from the design in reference points, so they map
//  1:1 when drawn inside a PassportPage.
//

import CoreGraphics

enum CollageTemplate {

    /// The photo cell rects for a given count, clamped to the 1…6+ templates.
    static func rects(photoCount: Int) -> [CGRect] {
        switch min(max(photoCount, 1), 6) {
        case 1:
            return [cell(0, 0, 143, 330)]
        case 2:
            return [
                cell(0, 0, 232, 192),
                cell(0, 198, 151, 132),
            ]
        case 3:
            return [
                cell(0, 0, 151, 330),
                cell(157, 0, 75, 106),
                cell(157, 112, 75, 106),
            ]
        case 4:
            return [
                cell(0, 0, 151, 175),
                cell(157, 0, 75, 84),
                cell(157, 90, 75, 85),
                cell(0, 181, 232, 149),
            ]
        case 5:
            return [
                cell(0, 0, 232, 140),
                cell(0, 146, 108, 184),
                cell(114, 146, 55, 88),
                cell(114, 240, 55, 90),
                cell(175, 146, 57, 184),
            ]
        default: // 6+
            return [
                cell(0, 0, 151, 107),
                cell(157, 0, 75, 107),
                cell(0, 113, 75, 217),
                cell(81, 113, 151, 100),
                cell(81, 219, 73, 111),
                cell(160, 219, 72, 111),
            ]
        }
    }

    private static func cell(_ x: CGFloat, _ y: CGFloat, _ w: CGFloat, _ h: CGFloat) -> CGRect {
        CGRect(x: x, y: y, width: w, height: h)
    }
}
