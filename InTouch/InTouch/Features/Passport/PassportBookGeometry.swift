//
//  PassportBookGeometry.swift
//  InTouch
//
//  How large the floating book is on its resting surface, and how far it sits
//  from the edge. Extracted from `PassportBookView` verbatim — pure arithmetic,
//  no view state, no holder, nothing mode-aware.
//
//  `surfaceMargin` lives here rather than on the view because `fitted` is its
//  only reader; keeping them apart meant a constant on the view that only one
//  method three hundred lines away cared about.
//

import CoreGraphics

enum PassportBookGeometry {

    /// Margin between the floating book and the edge of the resting surface.
    static let surfaceMargin: CGFloat = 28

    /// The largest `ratio`-proportioned rect that fits `avail` with a margin on
    /// every side — the floating book's footprint on the resting surface.
    static func fitted(ratio: CGFloat, in avail: CGSize) -> CGSize {
        let maxW = max(avail.width - 2 * surfaceMargin, 1)
        let maxH = max(avail.height - 2 * surfaceMargin, 1)
        var w = maxW
        var h = w / ratio
        if h > maxH { h = maxH; w = h * ratio }
        return CGSize(width: w, height: h)
    }
}
