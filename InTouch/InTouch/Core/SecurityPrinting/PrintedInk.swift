//
//  PrintedInk.swift
//  InTouch
//
//  The day/UV ink policy for the security-printing layer, and the conditional
//  halo that goes with it.
//
//  ONE OBJECT, TWO LIGHTING STATES. Daylight prints the whole printing layer in
//  the one subtle `ink` at whisper opacities, clearly beneath the content
//  hierarchy. Under UV the same geometry fluoresces in the stamp register,
//  hue-zoned like the reference. This decides only HOW an element is lit, never
//  what exists or where it sits.
//
//  Lifted out of SecurityPrinting.swift when the ID card needed to compose the
//  same primitives against its own (ID-1) geometry. Both were private there;
//  keeping the policy in one place is what stops the two compositions drifting
//  apart the first time an opacity is tuned.
//

import SwiftUI

extension PassportRenderMode {
    /// The ink an element prints in, given its UV hue/intensity and its
    /// daylight opacity. Pure colour policy — it draws nothing itself.
    func printedInk(uv uvHue: Color, uvOpacity: Double, day: Double) -> Color {
        isUV ? uvHue.opacity(uvOpacity) : Color.ink.opacity(day)
    }
}

/// A soft fluorescing halo. `.clear` disables it, so call sites can pass a
/// colour conditionally and read declaratively.
///
/// Deliberately kept a `ViewModifier` applied via `.modifier(...)` rather than
/// rewritten as a `View` extension. Both forms would serve the ID card equally,
/// but `.modifier` preserves the exact `ModifiedContent` wrapper the passport
/// already renders through — and structural view-tree changes are precisely
/// what perturbed sub-pixel output in the chevron accessibility work (see
/// DECISIONS.md 2026-07-25). Sugar can be added later behind its own gate.
struct Halo: ViewModifier {
    var color: Color
    var radius: CGFloat

    func body(content: Content) -> some View {
        if color == .clear {
            content
        } else {
            content.shadow(color: color, radius: radius)
        }
    }
}
