//
//  LabLandmarks.swift
//  InTouch
//
//  ⚠️ TEMPORARY — StampLab design lab. Safe to delete with the folder.
//
//  Bold drawn landmark silhouettes — the dominant central element of each city's
//  library stamp (see StampLibrary). A shared city stamp is only worth having if it
//  says something about the place, so each city gets its own landmark, struck big in
//  the middle with real ink weight. These are stylised, not literal: enough
//  proportion to read as the thing. A shipping stamp would use finished art.
//
//  Each fills the rect it's given. `aspect` (w ÷ h) lets the caller frame it
//  undistorted; `usesEvenOdd` is true where holes are punched (Big Ben's clock,
//  arches, windows, tiers) so they read as gaps in the ink.
//

import SwiftUI

enum Landmark: String, CaseIterable {
    case bigBen, colosseum, operaHouse, eiffel, bridge, temple, tajMahal
    case tram, skyline, torii, leaningTower, windmill

    var aspect: CGFloat {
        switch self {
        case .bigBen: 0.52
        case .colosseum: 1.5
        case .operaHouse: 1.7
        case .eiffel: 0.72
        case .bridge: 1.75
        case .temple: 1.4
        case .tajMahal: 1.35
        case .tram: 1.55
        case .skyline: 1.7
        case .torii: 1.25
        case .leaningTower: 0.5
        case .windmill: 0.95
        }
    }

    var usesEvenOdd: Bool {
        switch self {
        case .bigBen, .colosseum, .tram, .leaningTower: true
        default: false
        }
    }

    func path(in rect: CGRect) -> Path {
        switch self {
        case .bigBen: Self.bigBen(rect)
        case .colosseum: Self.colosseum(rect)
        case .operaHouse: Self.operaHouse(rect)
        case .eiffel: Self.eiffel(rect)
        case .bridge: Self.bridge(rect)
        case .temple: Self.temple(rect)
        case .tajMahal: Self.tajMahal(rect)
        case .tram: Self.tram(rect)
        case .skyline: Self.skyline(rect)
        case .torii: Self.torii(rect)
        case .leaningTower: Self.leaningTower(rect)
        case .windmill: Self.windmill(rect)
        }
    }

    // MARK: - Geometry helpers (fractions of rect, y down)

    private static func p(_ r: CGRect, _ x: CGFloat, _ y: CGFloat) -> CGPoint {
        CGPoint(x: r.minX + x * r.width, y: r.minY + y * r.height)
    }

    private static func rectF(_ r: CGRect, _ x: CGFloat, _ y: CGFloat, _ w: CGFloat, _ h: CGFloat) -> CGRect {
        CGRect(x: r.minX + x * r.width, y: r.minY + y * r.height, width: w * r.width, height: h * r.height)
    }

    private static func poly(_ r: CGRect, _ fractions: [(CGFloat, CGFloat)]) -> Path {
        var path = Path()
        for (index, f) in fractions.enumerated() {
            let point = p(r, f.0, f.1)
            if index == 0 { path.move(to: point) } else { path.addLine(to: point) }
        }
        path.closeSubpath()
        return path
    }

    // MARK: - Silhouettes

    private static func bigBen(_ r: CGRect) -> Path {
        var path = poly(r, [(0.50, 0.00), (0.585, 0.19), (0.55, 0.19), (0.62, 0.33), (0.565, 0.37),
                            (0.565, 1.00), (0.435, 1.00), (0.435, 0.37), (0.38, 0.33),
                            (0.45, 0.19), (0.415, 0.19)])
        path.addEllipse(in: rectF(r, 0.44, 0.46, 0.12, 0.12))        // clock (hole)
        return path
    }

    private static func colosseum(_ r: CGRect) -> Path {
        var path = Path()
        path.move(to: p(r, 0.08, 0.86))
        path.addLine(to: p(r, 0.08, 0.44))
        path.addQuadCurve(to: p(r, 0.92, 0.44), control: p(r, 0.50, 0.16))
        path.addLine(to: p(r, 0.92, 0.86))
        path.closeSubpath()
        for i in 0..<6 {                                            // arch openings (holes)
            let x = 0.15 + CGFloat(i) * 0.14
            var arch = Path()
            arch.move(to: p(r, x, 0.82))
            arch.addLine(to: p(r, x, 0.60))
            arch.addQuadCurve(to: p(r, x + 0.08, 0.60), control: p(r, x + 0.04, 0.52))
            arch.addLine(to: p(r, x + 0.08, 0.82))
            arch.closeSubpath()
            path.addPath(arch)
        }
        return path
    }

    private static func operaHouse(_ r: CGRect) -> Path {
        var path = Path()
        for sail in [(0.10, 0.26, 0.42), (0.30, 0.46, 0.64), (0.52, 0.66, 0.88)] as [(CGFloat, CGFloat, CGFloat)] {
            path.move(to: p(r, sail.0, 0.82))
            path.addLine(to: p(r, sail.1, 0.20))
            path.addQuadCurve(to: p(r, sail.2, 0.82), control: p(r, sail.1 + 0.10, 0.55))
            path.closeSubpath()
        }
        path.addRect(rectF(r, 0.06, 0.80, 0.88, 0.10))
        return path
    }

    private static func eiffel(_ r: CGRect) -> Path {
        var path = Path()
        path.move(to: p(r, 0.50, 0.00))
        path.addLine(to: p(r, 0.555, 0.30))
        path.addQuadCurve(to: p(r, 0.82, 0.94), control: p(r, 0.60, 0.64))
        path.addLine(to: p(r, 0.66, 0.94))
        path.addQuadCurve(to: p(r, 0.515, 0.36), control: p(r, 0.55, 0.62))
        path.addLine(to: p(r, 0.485, 0.36))
        path.addQuadCurve(to: p(r, 0.34, 0.94), control: p(r, 0.45, 0.62))
        path.addLine(to: p(r, 0.18, 0.94))
        path.addQuadCurve(to: p(r, 0.445, 0.30), control: p(r, 0.40, 0.64))
        path.closeSubpath()
        path.addRect(rectF(r, 0.40, 0.54, 0.20, 0.055))             // platform bar
        return path
    }

    private static func bridge(_ r: CGRect) -> Path {
        var path = Path()
        path.addRect(rectF(r, 0.04, 0.60, 0.92, 0.06))              // deck
        for tx in [0.28, 0.66] as [CGFloat] {
            path.addRect(rectF(r, tx, 0.26, 0.06, 0.40))           // towers
        }
        for fan in [(0.31, 0.05, 0.31), (0.31, 0.31, 0.50), (0.69, 0.50, 0.69), (0.69, 0.69, 0.95)] as [(CGFloat, CGFloat, CGFloat)] {
            path.move(to: p(r, fan.0, 0.28))
            path.addLine(to: p(r, fan.1, 0.60))
            path.addLine(to: p(r, fan.2, 0.60))
            path.closeSubpath()                                     // cable fans
        }
        return path
    }

    private static func temple(_ r: CGRect) -> Path {
        var path = poly(r, [(0.50, 0.10), (0.90, 0.34), (0.10, 0.34)])   // pediment
        path.addRect(rectF(r, 0.12, 0.34, 0.76, 0.07))                    // architrave
        for i in 0..<5 {
            path.addRect(rectF(r, 0.19 + CGFloat(i) * 0.155, 0.42, 0.05, 0.42))   // columns
        }
        path.addRect(rectF(r, 0.10, 0.84, 0.80, 0.08))                   // base
        return path
    }

    private static func tajMahal(_ r: CGRect) -> Path {
        var path = Path()
        path.addRect(rectF(r, 0.34, 0.52, 0.32, 0.34))                   // central block
        path.move(to: p(r, 0.34, 0.54))                                  // onion dome
        path.addCurve(to: p(r, 0.50, 0.22), control1: p(r, 0.34, 0.34), control2: p(r, 0.40, 0.22))
        path.addCurve(to: p(r, 0.66, 0.54), control1: p(r, 0.60, 0.22), control2: p(r, 0.66, 0.34))
        path.closeSubpath()
        path.addRect(rectF(r, 0.485, 0.12, 0.03, 0.12))                  // finial
        for mx in [0.16, 0.78] as [CGFloat] {
            path.addRect(rectF(r, mx, 0.36, 0.06, 0.50))                 // minarets
            path.addEllipse(in: rectF(r, mx - 0.005, 0.30, 0.07, 0.07))
        }
        path.addRect(rectF(r, 0.10, 0.86, 0.80, 0.07))                   // platform
        return path
    }

    /// Streetcar, side-on: body with a row of windows (holes), two wheels below, and
    /// a pantograph on the roof. Zürich's mark.
    private static func tram(_ r: CGRect) -> Path {
        var path = Path(roundedRect: rectF(r, 0.06, 0.30, 0.88, 0.44), cornerRadius: 0.05 * r.width)
        for i in 0..<4 {
            path.addRect(rectF(r, 0.13 + CGFloat(i) * 0.195, 0.37, 0.135, 0.17))   // windows (holes)
        }
        path.addRect(rectF(r, 0.06, 0.25, 0.88, 0.06))                  // roof strip
        path.addEllipse(in: rectF(r, 0.20, 0.76, 0.13, 0.13))           // wheels (below body)
        path.addEllipse(in: rectF(r, 0.67, 0.76, 0.13, 0.13))
        path.addPath(poly(r, [(0.47, 0.25), (0.53, 0.25), (0.51, 0.10), (0.49, 0.10)]))  // pantograph mast
        path.addRect(rectF(r, 0.40, 0.09, 0.20, 0.025))                 // pantograph bar
        return path
    }

    /// City skyline: a run of towers of varying height with one tall spire. New York.
    private static func skyline(_ r: CGRect) -> Path {
        var path = Path()
        let towers: [(CGFloat, CGFloat, CGFloat)] = [   // x, width, topY
            (0.02, 0.12, 0.56), (0.13, 0.12, 0.40), (0.25, 0.10, 0.64),
            (0.35, 0.15, 0.24), (0.50, 0.11, 0.50), (0.60, 0.13, 0.36),
            (0.72, 0.12, 0.60), (0.83, 0.14, 0.46),
        ]
        for tower in towers {
            path.addRect(rectF(r, tower.0, tower.2, tower.1, 0.92 - tower.2))
        }
        path.addRect(rectF(r, 0.415, 0.12, 0.02, 0.12))                 // spire on the tall one
        return path
    }

    /// Torii gate: two posts, a lower cross-beam, and an up-swept top beam. Tokyo.
    private static func torii(_ r: CGRect) -> Path {
        var path = Path()
        path.addRect(rectF(r, 0.25, 0.34, 0.07, 0.58))                  // posts
        path.addRect(rectF(r, 0.68, 0.34, 0.07, 0.58))
        path.addRect(rectF(r, 0.19, 0.50, 0.62, 0.07))                  // nuki (lower beam)
        // kasagi (top beam) with up-swept ends
        path.move(to: p(r, 0.06, 0.34))
        path.addLine(to: p(r, 0.10, 0.24))
        path.addLine(to: p(r, 0.90, 0.24))
        path.addLine(to: p(r, 0.94, 0.34))
        path.addLine(to: p(r, 0.84, 0.34))
        path.addLine(to: p(r, 0.82, 0.30))
        path.addLine(to: p(r, 0.18, 0.30))
        path.addLine(to: p(r, 0.16, 0.34))
        path.closeSubpath()
        return path
    }

    /// Leaning bell tower with colonnade tiers (holes), tilted right. Pisa.
    private static func leaningTower(_ r: CGRect) -> Path {
        // Body leans: bottom x0.28–0.60, top shifted right to x0.44–0.76.
        func leftX(_ y: CGFloat) -> CGFloat { 0.28 + 0.16 * (0.92 - y) / 0.86 }
        func rightX(_ y: CGFloat) -> CGFloat { 0.60 + 0.16 * (0.92 - y) / 0.86 }
        var path = poly(r, [(leftX(0.92), 0.92), (rightX(0.92), 0.92),
                            (rightX(0.06), 0.06), (leftX(0.06), 0.06)])
        for i in 0..<5 {                                                // colonnade tiers (holes)
            let y = 0.20 + CGFloat(i) * 0.145
            path.addRect(CGRect(x: r.minX + (leftX(y) + 0.02) * r.width,
                                y: r.minY + y * r.height,
                                width: (rightX(y) - leftX(y) - 0.04) * r.width,
                                height: 0.03 * r.height))
        }
        return path
    }

    /// Windmill: a tapered tower, a cap, and four crossed sails. Amsterdam.
    private static func windmill(_ r: CGRect) -> Path {
        var path = poly(r, [(0.36, 0.40), (0.64, 0.40), (0.72, 0.92), (0.28, 0.92)])   // body
        path.addPath(poly(r, [(0.32, 0.40), (0.68, 0.40), (0.50, 0.28)]))              // cap
        let hub = p(r, 0.50, 0.34)
        let length = 0.34 * r.width
        let halfWidth = 0.028 * r.width
        for degrees in stride(from: 45.0, to: 360.0, by: 90.0) {                       // four sails
            let angle = CGFloat(degrees) * .pi / 180
            let dir = CGVector(dx: cos(angle), dy: sin(angle))
            let perp = CGVector(dx: -dir.dy, dy: dir.dx)
            let tip = CGPoint(x: hub.x + dir.dx * length, y: hub.y + dir.dy * length)
            path.addPath(Path { blade in
                blade.move(to: CGPoint(x: hub.x + perp.dx * halfWidth, y: hub.y + perp.dy * halfWidth))
                blade.addLine(to: CGPoint(x: hub.x - perp.dx * halfWidth, y: hub.y - perp.dy * halfWidth))
                blade.addLine(to: CGPoint(x: tip.x - perp.dx * halfWidth, y: tip.y - perp.dy * halfWidth))
                blade.addLine(to: CGPoint(x: tip.x + perp.dx * halfWidth, y: tip.y + perp.dy * halfWidth))
                blade.closeSubpath()
            })
        }
        return path
    }
}

/// A `Shape` wrapper so a landmark can be filled/positioned directly.
struct LandmarkShape: Shape {
    let landmark: Landmark
    func path(in rect: CGRect) -> Path { landmark.path(in: rect) }
}

/// A five-point star — the neutral central mark for the generic (non-library) stamp,
/// and a small accent elsewhere.
struct StarShape: Shape {
    func path(in rect: CGRect) -> Path {
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let outer = min(rect.width, rect.height) / 2
        let inner = outer * 0.4
        var path = Path()
        for i in 0..<10 {
            let radius = i.isMultiple(of: 2) ? outer : inner
            let angle = CGFloat(i) / 10 * 2 * .pi - .pi / 2
            let point = CGPoint(x: center.x + radius * cos(angle), y: center.y + radius * sin(angle))
            if i == 0 { path.move(to: point) } else { path.addLine(to: point) }
        }
        path.closeSubpath()
        return path
    }
}
