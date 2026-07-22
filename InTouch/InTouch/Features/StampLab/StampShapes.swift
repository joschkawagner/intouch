//
//  StampShapes.swift
//  InTouch
//
//  ⚠️ TEMPORARY — StampLab design lab. This whole folder (Features/StampLab) is a
//  throwaway for developing the stamp vocabulary; deleting it removes the lab with
//  no effect on the app. See the (removed) DesignLab precedent in DECISIONS.md.
//
//  The outline geometry for every stamp shape family, studied from the real
//  references in docs/references/Passport_Stamps. Rather than one near-identical
//  `Shape` file per family, `StampShape` is an enum whose `path(in:)` fills
//  whatever rect it is handed. That single path serves three jobs so they can
//  never drift apart:
//    • the border   — stroke it
//    • the photo well — clip a photo to it
//    • the ink wear  — punch holes inside it
//
//  Handing `path(in:)` an *inset* rect gives a smaller concentric copy, which is
//  how the double rule (outer + inner border) comes from one definition.
//

import SwiftUI

/// One stamp outline. It fills the rect it is given, so the *caller* owns size and
/// proportion: a wide rect makes the oval an oval; a square rect makes it round.
enum StampShape: String, CaseIterable, Identifiable {
    case circle, oval, rectangle, roundedRectangle, triangle, hexagon, octagon, scallop, house

    var id: String { rawValue }

    /// How the city name is set: curved along the top edge, or on a straight line.
    /// Round-ish shapes arc; boxy shapes read better straight — the split the
    /// references use (Rome/Tokyo arc; New York/London/San Francisco run straight).
    enum TextLayout { case arc, straight }

    var textLayout: TextLayout {
        switch self {
        case .circle, .oval, .scallop, .octagon: .arc
        case .rectangle, .roundedRectangle, .triangle, .hexagon, .house: .straight
        }
    }

    /// Natural width ÷ height. The lab frames each stamp in a box of this aspect so
    /// an oval is an oval and a rectangle is a landscape card — not everything a
    /// square. Everything inside `LabStampView` is authored against this ratio.
    var aspect: CGFloat {
        switch self {
        case .circle, .scallop, .octagon, .house: 1.0
        case .oval: 1.42
        case .rectangle: 1.44
        case .roundedRectangle: 1.36
        case .triangle: 1.16
        case .hexagon: 1.5
        }
    }

    func path(in rect: CGRect) -> Path {
        switch self {
        case .circle:
            // Inscribe a centred square so it's a true circle even in a non-square rect.
            let side = min(rect.width, rect.height)
            let square = CGRect(x: rect.midX - side / 2, y: rect.midY - side / 2,
                                width: side, height: side)
            return Path(ellipseIn: square)

        case .oval:
            return Path(ellipseIn: rect)

        case .rectangle:
            return Path(rect)

        case .roundedRectangle:
            return Path(roundedRect: rect, cornerRadius: min(rect.width, rect.height) * 0.12)

        case .triangle:                              // point up
            return Self.polygon([.init(x: 0.5, y: 0.02), .init(x: 0.98, y: 0.98),
                                 .init(x: 0.02, y: 0.98)], in: rect)

        case .hexagon:                               // flat-top, so it elongates cleanly
            return Self.polygon([.init(x: 0.24, y: 0), .init(x: 0.76, y: 0),
                                 .init(x: 1, y: 0.5),
                                 .init(x: 0.76, y: 1), .init(x: 0.24, y: 1),
                                 .init(x: 0, y: 0.5)], in: rect)

        case .octagon:
            return Self.polygon([.init(x: 0.3, y: 0), .init(x: 0.7, y: 0),
                                 .init(x: 1, y: 0.3), .init(x: 1, y: 0.7),
                                 .init(x: 0.7, y: 1), .init(x: 0.3, y: 1),
                                 .init(x: 0, y: 0.7), .init(x: 0, y: 0.3)], in: rect)

        case .house:                                 // pitched roof over a box (Rio de Janeiro)
            return Self.polygon([.init(x: 0, y: 0.34), .init(x: 0.5, y: 0), .init(x: 1, y: 0.34),
                                 .init(x: 1, y: 1), .init(x: 0, y: 1)], in: rect)

        case .scallop:
            return Self.rosette(in: rect, lobes: 16, depth: 0.052)
        }
    }

    /// A closed polygon from points given as 0…1 fractions of `rect`.
    private static func polygon(_ fractions: [CGPoint], in rect: CGRect) -> Path {
        var path = Path()
        for (index, fraction) in fractions.enumerated() {
            let point = CGPoint(x: rect.minX + fraction.x * rect.width,
                                y: rect.minY + fraction.y * rect.height)
            if index == 0 { path.move(to: point) } else { path.addLine(to: point) }
        }
        path.closeSubpath()
        return path
    }

    /// A smooth N-lobed rosette (Tokyo's scalloped ring). The radius breathes in and
    /// out as `cos(lobes · θ)`, sampled densely so the bumps read as round scallops
    /// rather than spikes. `depth` is bump height as a fraction of the base radius.
    private static func rosette(in rect: CGRect, lobes: Int, depth: CGFloat) -> Path {
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let base = min(rect.width, rect.height) / 2 * (1 - depth)
        let amplitude = base * depth
        var path = Path()
        let steps = 240
        for step in 0...steps {
            let theta = CGFloat(step) / CGFloat(steps) * 2 * .pi
            let radius = base + amplitude * cos(CGFloat(lobes) * theta)
            let point = CGPoint(x: center.x + radius * cos(theta),
                                y: center.y + radius * sin(theta))
            if step == 0 { path.move(to: point) } else { path.addLine(to: point) }
        }
        path.closeSubpath()
        return path
    }
}

/// A SwiftUI `Shape` wrapper so a `StampShape` works with `.fill`, `.stroke`,
/// `.clipShape` and `.mask` directly. `inset` shrinks it concentrically — that is
/// how the inner of a double border and the photo well are struck from one shape.
struct StampOutline: Shape {
    let shape: StampShape
    var inset: CGFloat = 0

    func path(in rect: CGRect) -> Path {
        shape.path(in: rect.insetBy(dx: inset, dy: inset))
    }
}
