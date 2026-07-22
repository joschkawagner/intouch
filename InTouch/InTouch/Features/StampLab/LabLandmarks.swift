//
//  LabLandmarks.swift
//  InTouch
//
//  ⚠️ TEMPORARY — StampLab design lab. Safe to delete with the folder.
//
//  Bold drawn landmark silhouettes, so an ink-only stamp has a SUBSTANTIAL central
//  element with real ink weight — not a thin icon floating in white space. Real
//  passport stamps anchor on a big struck landmark (see passport-world.jpg: the
//  Leaning Tower, the temple, the deer). These are stylised, not literal — enough
//  proportion to read as the thing; a shipping stamp would use finished art.
//
//  Each landmark fills the rect it's given. `aspect` (w ÷ h) lets the caller frame
//  it undistorted; `usesEvenOdd` is true for the ones with punched holes (Big Ben's
//  clock, the Colosseum's arches) so the holes read as gaps in the ink.
//

import SwiftUI

enum Landmark: String, CaseIterable {
    case bigBen, colosseum, operaHouse, eiffel, bridge, temple, tajMahal

    /// Natural width ÷ height, so the caller can size a frame that doesn't squash it.
    var aspect: CGFloat {
        switch self {
        case .bigBen: 0.52
        case .colosseum: 1.5
        case .operaHouse: 1.7
        case .eiffel: 0.72
        case .bridge: 1.75
        case .temple: 1.4
        case .tajMahal: 1.35
        }
    }

    var usesEvenOdd: Bool {
        switch self {
        case .bigBen, .colosseum: true
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
        }
    }

    // MARK: - Silhouettes (fractions of rect, y down)

    private static func p(_ r: CGRect, _ x: CGFloat, _ y: CGFloat) -> CGPoint {
        CGPoint(x: r.minX + x * r.width, y: r.minY + y * r.height)
    }

    /// Clock tower: shaft, wider belfry, spire, with a knocked-out clock face.
    private static func bigBen(_ r: CGRect) -> Path {
        var path = Path()
        let pts: [(CGFloat, CGFloat)] = [
            (0.50, 0.00), (0.585, 0.19), (0.55, 0.19), (0.62, 0.33), (0.565, 0.37),
            (0.565, 1.00), (0.435, 1.00), (0.435, 0.37), (0.38, 0.33), (0.45, 0.19),
            (0.415, 0.19),
        ]
        path.move(to: p(r, pts[0].0, pts[0].1))
        for pt in pts.dropFirst() { path.addLine(to: p(r, pt.0, pt.1)) }
        path.closeSubpath()
        // Clock face — a hole (needs even-odd fill).
        path.addEllipse(in: CGRect(x: r.minX + 0.44 * r.width, y: r.minY + 0.46 * r.height,
                                   width: 0.12 * r.width, height: 0.12 * r.height))
        return path
    }

    /// Amphitheatre: a dome-topped arcade with a row of arch openings punched out.
    private static func colosseum(_ r: CGRect) -> Path {
        var path = Path()
        path.move(to: p(r, 0.08, 0.86))
        path.addLine(to: p(r, 0.08, 0.44))
        path.addQuadCurve(to: p(r, 0.92, 0.44), control: p(r, 0.50, 0.16))
        path.addLine(to: p(r, 0.92, 0.86))
        path.closeSubpath()
        // Arch openings along the lower band.
        for i in 0..<6 {
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

    /// Sydney Opera House: overlapping shell sails on a platform.
    private static func operaHouse(_ r: CGRect) -> Path {
        var path = Path()
        let sails: [(CGFloat, CGFloat, CGFloat)] = [   // baseLeft, peakX, baseRight
            (0.10, 0.26, 0.42), (0.30, 0.46, 0.64), (0.52, 0.66, 0.88),
        ]
        for sail in sails {
            path.move(to: p(r, sail.0, 0.82))
            path.addLine(to: p(r, sail.1, 0.20))
            path.addQuadCurve(to: p(r, sail.2, 0.82), control: p(r, sail.1 + 0.10, 0.55))
            path.closeSubpath()
        }
        path.addRect(CGRect(x: r.minX + 0.06 * r.width, y: r.minY + 0.80 * r.height,
                            width: 0.88 * r.width, height: 0.10 * r.height))
        return path
    }

    /// Eiffel Tower: flared curved legs to a point, with a platform bar.
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
        path.addRect(CGRect(x: r.minX + 0.40 * r.width, y: r.minY + 0.54 * r.height,
                            width: 0.20 * r.width, height: 0.055 * r.height))
        return path
    }

    /// Suspension bridge: two towers, a deck, and triangular cable fans.
    private static func bridge(_ r: CGRect) -> Path {
        var path = Path()
        path.addRect(CGRect(x: r.minX + 0.04 * r.width, y: r.minY + 0.60 * r.height,
                            width: 0.92 * r.width, height: 0.06 * r.height))   // deck
        for tx in [0.28, 0.66] as [CGFloat] {                                   // towers
            path.addRect(CGRect(x: r.minX + tx * r.width, y: r.minY + 0.26 * r.height,
                                width: 0.06 * r.width, height: 0.40 * r.height))
        }
        let fans: [(CGFloat, CGFloat, CGFloat)] = [   // topX, leftX, rightX at deck
            (0.31, 0.05, 0.31), (0.31, 0.31, 0.50), (0.69, 0.50, 0.69), (0.69, 0.69, 0.95),
        ]
        for fan in fans {
            path.move(to: p(r, fan.0, 0.28))
            path.addLine(to: p(r, fan.1, 0.60))
            path.addLine(to: p(r, fan.2, 0.60))
            path.closeSubpath()
        }
        return path
    }

    /// Classical temple: pediment, architrave and a colonnade on a base.
    private static func temple(_ r: CGRect) -> Path {
        var path = Path()
        path.move(to: p(r, 0.50, 0.10))                 // pediment
        path.addLine(to: p(r, 0.90, 0.34))
        path.addLine(to: p(r, 0.10, 0.34))
        path.closeSubpath()
        path.addRect(CGRect(x: r.minX + 0.12 * r.width, y: r.minY + 0.34 * r.height,
                            width: 0.76 * r.width, height: 0.07 * r.height))    // architrave
        for i in 0..<5 {                                                        // columns
            let x = 0.19 + CGFloat(i) * 0.155
            path.addRect(CGRect(x: r.minX + x * r.width, y: r.minY + 0.42 * r.height,
                                width: 0.05 * r.width, height: 0.42 * r.height))
        }
        path.addRect(CGRect(x: r.minX + 0.10 * r.width, y: r.minY + 0.84 * r.height,
                            width: 0.80 * r.width, height: 0.08 * r.height))    // base
        return path
    }

    /// Taj Mahal: onion dome and block, flanked by minarets, on a platform.
    private static func tajMahal(_ r: CGRect) -> Path {
        var path = Path()
        // Central block.
        path.addRect(CGRect(x: r.minX + 0.34 * r.width, y: r.minY + 0.52 * r.height,
                            width: 0.32 * r.width, height: 0.34 * r.height))
        // Onion dome.
        path.move(to: p(r, 0.34, 0.54))
        path.addCurve(to: p(r, 0.50, 0.22), control1: p(r, 0.34, 0.34), control2: p(r, 0.40, 0.22))
        path.addCurve(to: p(r, 0.66, 0.54), control1: p(r, 0.60, 0.22), control2: p(r, 0.66, 0.34))
        path.closeSubpath()
        path.addRect(CGRect(x: r.minX + 0.485 * r.width, y: r.minY + 0.12 * r.height,
                            width: 0.03 * r.width, height: 0.12 * r.height))    // finial
        for mx in [0.16, 0.78] as [CGFloat] {                                   // minarets
            path.addRect(CGRect(x: r.minX + mx * r.width, y: r.minY + 0.36 * r.height,
                                width: 0.06 * r.width, height: 0.50 * r.height))
            path.addEllipse(in: CGRect(x: r.minX + (mx - 0.005) * r.width, y: r.minY + 0.30 * r.height,
                                       width: 0.07 * r.width, height: 0.07 * r.height))
        }
        path.addRect(CGRect(x: r.minX + 0.10 * r.width, y: r.minY + 0.86 * r.height,
                            width: 0.80 * r.width, height: 0.07 * r.height))    // platform
        return path
    }
}

/// A `Shape` wrapper so a landmark can be filled/positioned directly.
struct LandmarkShape: Shape {
    let landmark: Landmark
    func path(in rect: CGRect) -> Path { landmark.path(in: rect) }
}

/// A bold official emblem: a struck medallion with a knocked-out star, a heavy ring
/// and a rank of radiating ticks. The other "weighty centre" when a stamp has no
/// landmark — reads as a seal, not an icon.
struct EmblemView: View {
    let ink: Color

    var body: some View {
        GeometryReader { proxy in
            let side = min(proxy.size.width, proxy.size.height)
            let center = CGPoint(x: proxy.size.width / 2, y: proxy.size.height / 2)
            ZStack {
                MedallionShape(outer: side * 0.42, star: side * 0.24, center: center)
                    .fill(ink, style: FillStyle(eoFill: true))
                Circle()
                    .stroke(ink, lineWidth: side * 0.045)
                    .frame(width: side * 0.94, height: side * 0.94)
                ForEach(0..<16, id: \.self) { index in
                    Capsule()
                        .fill(ink)
                        .frame(width: side * 0.018, height: side * 0.06)
                        .offset(y: -side * 0.40)
                        .rotationEffect(.degrees(Double(index) / 16 * 360))
                }
            }
        }
    }
}

/// A filled disc with a five-point star punched out (even-odd fill).
private struct MedallionShape: Shape {
    let outer: CGFloat
    let star: CGFloat
    let center: CGPoint

    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.addEllipse(in: CGRect(x: center.x - outer, y: center.y - outer,
                                   width: outer * 2, height: outer * 2))
        path.addPath(starPath(center: center, outer: star, inner: star * 0.4))
        return path
    }

    private func starPath(center: CGPoint, outer: CGFloat, inner: CGFloat) -> Path {
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
