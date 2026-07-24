//
//  ContourField.swift
//  InTouch
//
//  The topographic contour field — irregular nested iso-lines over a seeded
//  scalar terrain, the passport's full-page ground artwork (UV pass; replaces
//  the uniform WaveField ripples). Contours are on-theme (cities, geography)
//  and read like real security printing: lines that merge, nest and run off
//  the page edge instead of tiling. The contours CARRY the page — every other
//  printing element is subordinate texture (see SecurityPrinting).
//
//  The terrain is a sum of seeded Gaussian bumps (some negative — valleys, so
//  ridges merge rather than sit as separate blobs), sampled on a coarse grid
//  and contoured with marching squares. Because the field is only ever
//  *stroked*, the per-cell segments never need chaining into ordered loops —
//  an unordered bag of tiny segments in one Path strokes identically.
//
//  Geometry is 100% derived from SeededGenerator (launch-stable), so the same
//  seed prints the same page forever, in daylight and under UV alike — the
//  one-object / two-lighting-states rule depends on this.
//
//  A page draws the SAME terrain several times via `band` (minor solid lines,
//  a dotted interleave, heavier index contours) and — under UV — via
//  `bloomBucket`: a second, smoother seeded field partitions the page into
//  intensity regions, so fluorescence blooms and fades along the linework the
//  way real UV ink pools, instead of rendering flat. The buckets partition
//  the SAME segments; their union is the complete geometry, so daylight (one
//  instance, no bucket) and UV (one instance per bucket) print identical
//  lines — bloom is lighting, not geometry.
//
//  The sampled terrain is memoized per (seed, params, size) so the several
//  instances a page draws share one field evaluation.
//

import SwiftUI

struct ContourField: Shape {

    /// Which subset of iso levels this instance draws.
    enum Band {
        case minor, dotted, index

        func includes(_ level: Int, indexEvery: Int) -> Bool {
            let isIndex = (level + 1) % indexEvery == 0
            switch self {
            case .index:  return isIndex
            case .minor:  return !isIndex && level.isMultiple(of: 2)
            case .dotted: return !isIndex && !level.isMultiple(of: 2)
            }
        }
    }

    /// Stable page identity — same seed, same terrain, forever.
    var seed: String
    var band: Band = .minor
    /// Total iso levels across all bands.
    var levels: Int = 12
    /// Every Nth level is an index contour.
    var indexEvery: Int = 4
    /// Terrain complexity — peaks and valleys summed into the field.
    var bumpCount: Int = 9
    /// Sample spacing in reference points. Smaller = smoother, costlier.
    var gridStep: CGFloat = 3
    /// UV bloom: draw only cells whose bloom-field value falls in this bucket
    /// (of `bloomBuckets`). `nil` draws everything — the daylight instance.
    var bloomBucket: Int?
    var bloomBuckets: Int = 3

    func path(in rect: CGRect) -> Path {
        let cols = Int((rect.width / gridStep).rounded(.up))
        let rows = Int((rect.height / gridStep).rounded(.up))
        guard cols > 1, rows > 1 else { return Path() }

        let sample = Self.sample(seed: seed, bumpCount: bumpCount,
                                 gridStep: gridStep, rect: rect,
                                 rows: rows, cols: cols)

        let myLevels = (0..<levels).filter { band.includes($0, indexEvery: indexEvery) }
        let isos = myLevels.map { sample.lo + sample.span * (CGFloat($0) + 0.5) / CGFloat(levels) }

        var path = Path()
        for r in 0..<rows {
            let y0 = rect.minY + CGFloat(r) * gridStep
            let y1 = y0 + gridStep
            for c in 0..<cols {
                // UV bloom partition — whole cells belong to one intensity
                // region, so neighbouring segments bloom together. Buckets cut
                // at QUANTILES of the sampled bloom values (equal page area
                // each), so no bucket can ever span the page as one band —
                // the range-based cut produced a diagonal "shadow" when the
                // field happened to be a single smooth gradient.
                if let bucket = bloomBucket {
                    let v = sample.bloom[r][c]
                    var cellBucket = 0
                    for t in 1..<bloomBuckets
                    where v >= sample.bloomSorted[sample.bloomSorted.count * t / bloomBuckets] {
                        cellBucket = t
                    }
                    guard cellBucket == bucket else { continue }
                }

                let x0 = rect.minX + CGFloat(c) * gridStep
                let x1 = x0 + gridStep
                let tl = sample.field[r][c], tr = sample.field[r][c + 1]
                let br = sample.field[r + 1][c + 1], bl = sample.field[r + 1][c]

                for iso in isos {
                    var code = 0
                    if tl >= iso { code |= 1 }
                    if tr >= iso { code |= 2 }
                    if br >= iso { code |= 4 }
                    if bl >= iso { code |= 8 }
                    if code == 0 || code == 15 { continue }

                    func lerp(_ a: CGFloat, _ b: CGFloat) -> CGFloat {
                        (iso - a) / (b - a)
                    }
                    let top    = CGPoint(x: x0 + lerp(tl, tr) * gridStep, y: y0)
                    let bottom = CGPoint(x: x0 + lerp(bl, br) * gridStep, y: y1)
                    let left   = CGPoint(x: x0, y: y0 + lerp(tl, bl) * gridStep)
                    let right  = CGPoint(x: x1, y: y0 + lerp(tr, br) * gridStep)

                    let segments: [(CGPoint, CGPoint)]
                    switch code {
                    case 1:  segments = [(left, top)]
                    case 2:  segments = [(top, right)]
                    case 3:  segments = [(left, right)]
                    case 4:  segments = [(right, bottom)]
                    case 6:  segments = [(top, bottom)]
                    case 7:  segments = [(left, bottom)]
                    case 8:  segments = [(bottom, left)]
                    case 9:  segments = [(top, bottom)]
                    case 11: segments = [(right, bottom)]
                    case 12: segments = [(left, right)]
                    case 13: segments = [(top, right)]
                    case 14: segments = [(left, top)]
                    case 5:  // TL+BR high — saddle; centre disambiguates.
                        let centre = (tl + tr + br + bl) / 4
                        segments = centre >= iso
                            ? [(top, right), (left, bottom)]
                            : [(left, top), (right, bottom)]
                    default: // 10: TR+BL high — saddle.
                        let centre = (tl + tr + br + bl) / 4
                        segments = centre >= iso
                            ? [(left, top), (right, bottom)]
                            : [(top, right), (left, bottom)]
                    }

                    for (a, b) in segments {
                        if band == .dotted {
                            let mid = CGPoint(x: (a.x + b.x) / 2, y: (a.y + b.y) / 2)
                            path.addEllipse(in: CGRect(x: mid.x - 0.4, y: mid.y - 0.4,
                                                       width: 0.8, height: 0.8))
                        } else {
                            path.move(to: a)
                            path.addLine(to: b)
                        }
                    }
                }
            }
        }
        return path
    }

    // MARK: - Sampled terrain (memoized)

    private struct FieldSample {
        var field: [[CGFloat]]
        var lo, span: CGFloat
        var bloom: [[CGFloat]]
        /// All sampled bloom values, sorted — bucket thresholds are quantiles
        /// of this, so every bucket covers the same page area on every seed.
        var bloomSorted: [CGFloat]
    }

    /// One field evaluation per page: every band/bucket instance a page draws
    /// shares the sampled terrain. Keys are few (one per passport page size),
    /// values small — an unbounded dictionary is fine. Main-thread only
    /// (SwiftUI calls `path(in:)` during rendering).
    private static var cache: [String: FieldSample] = [:]

    private static func sample(seed: String, bumpCount: Int, gridStep: CGFloat,
                               rect: CGRect, rows: Int, cols: Int) -> FieldSample {
        let key = "\(seed)|\(bumpCount)|\(gridStep)|\(Int(rect.width))x\(Int(rect.height))"
        if let hit = cache[key] { return hit }

        struct Bump { var cx, cy, amp, twoSigmaSq: CGFloat }

        // Terrain bumps. Centres are inflated 40pt beyond the page so ridges
        // enter from off-page (full bleed, printing cropped by the edge).
        var rng = SeededGenerator(seed: seed + "/contours")
        let bumps: [Bump] = (0..<bumpCount).map { _ in
            let cx = rect.minX + CGFloat(rng.next(in: -40...(rect.width + 40)))
            let cy = rect.minY + CGFloat(rng.next(in: -40...(rect.height + 40)))
            let sign: CGFloat = rng.next(in: 0...1) < 0.4 ? -1 : 1
            let amp = sign * CGFloat(rng.next(in: 0.55...1.0))
            let sigma = CGFloat(rng.next(in: 24...72))
            return Bump(cx: cx, cy: cy, amp: amp, twoSigmaSq: 2 * sigma * sigma)
        }

        // Bloom bumps: a smoother, always-positive field that maps where the
        // UV ink pools hot vs fades — spatial variation, not geometry. Twelve
        // patches at 20–48pt keep the pooling at sub-page scale; the earlier
        // four page-sized patches collapsed into one smooth gradient whose
        // buckets read as a broad shadow band lying across the page.
        var bloomRng = SeededGenerator(seed: seed + "/bloom")
        let bloomBumps: [Bump] = (0..<12).map { _ in
            let cx = rect.minX + CGFloat(bloomRng.next(in: -40...(rect.width + 40)))
            let cy = rect.minY + CGFloat(bloomRng.next(in: -40...(rect.height + 40)))
            let amp = CGFloat(bloomRng.next(in: 0.5...1.0))
            let sigma = CGFloat(bloomRng.next(in: 20...48))
            return Bump(cx: cx, cy: cy, amp: amp, twoSigmaSq: 2 * sigma * sigma)
        }

        func evaluate(_ bumps: [Bump], x: CGFloat, y: CGFloat) -> CGFloat {
            var v: CGFloat = 0
            for b in bumps {
                let dx = x - b.cx, dy = y - b.cy
                v += b.amp * exp(-(dx * dx + dy * dy) / b.twoSigmaSq)
            }
            return v
        }

        var field = [[CGFloat]](repeating: [CGFloat](repeating: 0, count: cols + 1),
                                count: rows + 1)
        var bloom = field
        var lo = CGFloat.greatestFiniteMagnitude, hi = -lo
        var bloomFlat: [CGFloat] = []
        bloomFlat.reserveCapacity((rows + 1) * (cols + 1))
        for r in 0...rows {
            let y = rect.minY + CGFloat(r) * gridStep
            for c in 0...cols {
                let x = rect.minX + CGFloat(c) * gridStep
                let v = evaluate(bumps, x: x, y: y)
                field[r][c] = v
                lo = min(lo, v); hi = max(hi, v)
                let b = evaluate(bloomBumps, x: x, y: y)
                bloom[r][c] = b
                bloomFlat.append(b)
            }
        }

        let result = FieldSample(field: field, lo: lo, span: max(hi - lo, 0.0001),
                                 bloom: bloom, bloomSorted: bloomFlat.sorted())
        cache[key] = result
        return result
    }
}

#Preview {
    ZStack {
        Color.paper
        ContourField(seed: "preview", band: .minor)
            .stroke(Color.ink.opacity(0.3), lineWidth: 0.55)
        ContourField(seed: "preview", band: .dotted)
            .stroke(Color.ink.opacity(0.3), lineWidth: 0.55)
        ContourField(seed: "preview", band: .index)
            .stroke(Color.ink.opacity(0.5), lineWidth: 0.7)
    }
    .frame(width: 232, height: 330)
}
