//
//  ReferenceOrigin.swift
//  InTouch
//
//  Absolute placement inside a fixed reference space.
//
//  Documents in this app are authored at one fixed size and then scaled to fit
//  whatever frame they are handed — the passport page at its ID-3 232×330, and
//  (from the ID card) other document geometries besides. Inside such a space
//  every field is pinned to the coordinate the design specifies rather than
//  stacked, so the design measurements map 1:1 to points and the content shares
//  one coordinate system with the security printing drawn beneath it.
//
//  Lifted out of PassportPage.swift verbatim when a second feature needed it.
//  The implementation is unchanged: a frame that fills its parent aligned
//  top-leading, then an offset. No wrapper view, so it adds no level to the
//  view tree.
//

import SwiftUI

extension View {
    /// Pins this view's top-left corner to (`x`, `y`) in the enclosing
    /// reference space. Use inside a document container's content (a ZStack),
    /// where every field is placed by its design coordinate.
    func referenceOrigin(x: CGFloat, y: CGFloat) -> some View {
        frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
            .offset(x: x, y: y)
    }
}
