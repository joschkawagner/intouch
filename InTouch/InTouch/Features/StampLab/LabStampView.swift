//
//  LabStampView.swift
//  InTouch
//
//  ⚠️ TEMPORARY — StampLab design lab. Safe to delete with the folder.
//
//  Renders ONE lab stamp end to end. Like the shipping StampView it draws into a
//  fixed canonical box and then `.scaleEffect`-scales to the requested height, so
//  proportions hold identically whether a stamp is small on the scattered page or
//  large in the detail rail. The canonical box is `200 × (200 · aspect)`.
//
//  Four layouts, chosen by whether there's a photo and how the shape sets text:
//    • postage    — photo card, perforated edge, caption strip     (photo, boxy)
//    • ink-frame  — photo clipped inside the shape, city in the margin (photo)
//    • arc ink    — round seal: city over the top, country under, weighty centre
//    • straight ink — boxy stamp: city, weighty centre, country
//  An ink stamp's centre is a bold LANDMARK, an EMBLEM, or a heavy DATE BLOCK
//  (LabStamp.center) so it carries real ink weight, not a thin icon in white space.
//  Then the double rule and the seeded ink wear go on top of all of them.
//

import SwiftUI

struct LabStampView: View {

    let stamp: LabStamp
    /// Rendered height in points; width follows the shape's aspect.
    var height: CGFloat = 200
    /// Replays the press-down landing on tap. Off on the (display-only) page.
    var landsOnTap: Bool = false

    @State private var pressScale: CGFloat = 1

    private static let canonical: CGFloat = 200
    private static let outerInset: CGFloat = 6
    private static let innerInset: CGFloat = 13

    private var aspect: CGFloat { stamp.shape.aspect }
    private var boxWidth: CGFloat { Self.canonical * aspect }
    private var ink: Color { stamp.ink.color }
    private var marks: LabStampMarks { LabStampMarks(seed: stamp.id) }
    private var wear: Double { stamp.wear ?? 0.3 }

    var body: some View {
        // The tap gesture is attached ONLY when interactive, so the scattered page
        // (landsOnTap == false) has no tap targets — it's a display artifact.
        if landsOnTap {
            scaledFace.onTapGesture { land() }
        } else {
            scaledFace
        }
    }

    private var scaledFace: some View {
        face
            .frame(width: boxWidth, height: Self.canonical)
            .scaleEffect(height / Self.canonical)
            .frame(width: height * aspect, height: height)
            .rotationEffect(rotation)
            .scaleEffect(pressScale)
            .accessibilityElement(children: .ignore)
            .accessibilityLabel("\(stamp.city), \(Self.shortDate.string(from: stamp.date)), \(stamp.shape.rawValue)")
    }

    // MARK: - Assembly

    private var face: some View {
        ZStack {
            body(for: stamp)
            if stamp.frameStyle != .postage || !stamp.hasPhoto { borders }
        }
        .frame(width: boxWidth, height: Self.canonical)
        .foregroundStyle(ink)
        .inkWear(seed: stamp.id, shape: stamp.shape, inset: Self.outerInset, strength: wear)
    }

    @ViewBuilder
    private func body(for stamp: LabStamp) -> some View {
        if stamp.hasPhoto {
            switch stamp.frameStyle {
            case .postage:  postageBody
            case .inkFrame: inkFrameBody
            }
        } else if stamp.shape.textLayout == .arc {
            arcInkBody
        } else {
            straightInkBody
        }
    }

    private var borders: some View {
        ZStack {
            StampOutline(shape: stamp.shape, inset: Self.outerInset)
                .stroke(ink, lineWidth: 2.4)
            StampOutline(shape: stamp.shape, inset: Self.innerInset)
                .stroke(ink.opacity(0.6),
                        style: StrokeStyle(lineWidth: 1, dash: dashedInner ? [4, 3] : []))
        }
    }

    // MARK: - Layout 1: postage (photo card, perforated)

    private var postageBody: some View {
        let card = CGSize(width: boxWidth - 12, height: Self.canonical - 12)
        return ZStack {
            Color.paper
            VStack(spacing: 0) {
                Image(stamp.photo!)
                    .resizable().scaledToFill()
                    .frame(width: card.width, height: card.height * 0.7)
                    .clipped()
                    .saturation(0.85)                 // calmer, so photos don't dominate
                    .overlay(ink.opacity(0.06))
                captionStrip
                    .frame(width: card.width, height: card.height * 0.3)
                    .background(Color.paper)
            }
            .frame(width: card.width, height: card.height)
            .overlay(Rectangle().stroke(ink, lineWidth: 1.4))
            Perforations(cardSize: card, box: CGSize(width: boxWidth, height: Self.canonical))
        }
    }

    private var captionStrip: some View {
        HStack(alignment: .center, spacing: 4) {
            VStack(alignment: .leading, spacing: 1) {
                Text(stamp.city.uppercased()).font(Typography.stampDate).tracking(1)
                Text(stamp.country.uppercased()).font(Typography.stampMark).tracking(1).opacity(0.75)
            }
            Spacer(minLength: 2)
            VStack(alignment: .trailing, spacing: 1) {
                Text(Self.shortDate.string(from: stamp.date)).font(Typography.stampMark)
                Image(systemName: marks.landmark).resizable().scaledToFit().frame(height: 12).opacity(0.8)
            }
        }
        .minimumScaleFactor(0.6).lineLimit(1)
        .padding(.horizontal, 8)
    }

    // MARK: - Layout 2: ink-frame (photo clipped inside the shape)

    @ViewBuilder
    private var inkFrameBody: some View {
        if stamp.shape.textLayout == .arc {
            ZStack {
                photoWell(inset: 40)
                LabArcText(text: stamp.city.uppercased(), radius: 78, edge: .top)
                LabArcText(text: stamp.country.uppercased(), radius: 78, edge: .bottom,
                           uiFont: Typography.stampMarkUIFont)
                Text(Self.shortDate.string(from: stamp.date))
                    .font(Typography.stampMark).tracking(1)
                    .padding(.horizontal, 5).padding(.vertical, 1)
                    .background(Color.paper.opacity(0.85))
                    .offset(y: Self.canonical * 0.28)
            }
        } else {
            ZStack(alignment: .bottom) {
                photoWell(inset: 9)
                VStack(spacing: 0) {
                    Text(stamp.city.uppercased()).font(Typography.stampDate).tracking(1.5)
                    Text(Self.shortDate.string(from: stamp.date)).font(Typography.stampMark).tracking(1)
                }
                .foregroundStyle(Color.paper)
                .padding(.vertical, 5).frame(maxWidth: .infinity)
                .background(ink.opacity(0.62))
                .padding(.horizontal, Self.innerInset + 2).padding(.bottom, Self.innerInset + 2)
            }
        }
    }

    private func photoWell(inset: CGFloat) -> some View {
        Image(stamp.photo!)
            .resizable().scaledToFill()
            .frame(width: boxWidth - inset * 2, height: Self.canonical - inset * 2)
            .clipShape(StampOutline(shape: stamp.shape))
            .saturation(0.72)
            .overlay(StampOutline(shape: stamp.shape).fill(ink.opacity(0.14)))
    }

    // MARK: - Layout 3: arc ink (round seal, weighty centre)

    private var arcInkBody: some View {
        ZStack {
            LabArcText(text: stamp.city.uppercased(), radius: 78, edge: .top)
            LabArcText(text: stamp.country.uppercased(), radius: 78, edge: .bottom,
                       uiFont: Typography.stampMarkUIFont)
            inkMiddle(centerBox: CGSize(width: boxWidth * 0.58, height: Self.canonical * 0.46))
        }
    }

    // MARK: - Layout 4: straight ink (boxy stamp, weighty centre)

    private var straightInkBody: some View {
        VStack(spacing: 4) {
            Text(stamp.city.uppercased())
                .font(Typography.stampDate).tracking(1.4)
                .minimumScaleFactor(0.5).lineLimit(1)
            inkMiddle(centerBox: CGSize(width: boxWidth * 0.6, height: Self.canonical * 0.32))
            Text(stamp.country.uppercased())
                .font(Typography.stampMark).tracking(1).opacity(0.72)
                .minimumScaleFactor(0.5).lineLimit(1)
        }
        .padding(.horizontal, Self.innerInset + 4)
        .padding(.top, topBias)          // nudge into the wide part of a triangle/house
    }

    private var topBias: CGFloat {
        switch stamp.shape {
        case .triangle: 30
        case .house: 16
        default: 0
        }
    }

    // MARK: - The weighty centre (landmark / emblem / date block)

    private func inkMiddle(centerBox: CGSize) -> some View {
        VStack(spacing: 5) {
            centerGraphic(maxWidth: centerBox.width, maxHeight: centerBox.height)
            if case .dateBlock = stamp.center {
                // The stacked date is the graphic — no separate date line.
            } else {
                dateLine(heavy: isEmblem)
            }
            if let word = stamp.word {
                Text(word).font(Typography.stampMark).tracking(1.4).opacity(0.85)
            }
        }
    }

    @ViewBuilder
    private func centerGraphic(maxWidth: CGFloat, maxHeight: CGFloat) -> some View {
        switch stamp.center {
        case .landmark(let landmark):
            let size = fit(aspect: landmark.aspect, maxWidth: maxWidth, maxHeight: maxHeight)
            LandmarkShape(landmark: landmark)
                .fill(ink, style: FillStyle(eoFill: landmark.usesEvenOdd))
                .frame(width: size.width, height: size.height)
        case .emblem:
            let side = min(maxWidth, maxHeight)
            EmblemView(ink: ink).frame(width: side, height: side)
        case .dateBlock:
            stackedDate
        }
    }

    /// The heavy stacked date — day / month / year between two thick rules. The hero
    /// of a date-block stamp; the ref does this ("NOV 4 / 2-PM / 1963").
    private var stackedDate: some View {
        VStack(spacing: 1) {
            heavyRule
            Text(Self.day.string(from: stamp.date)).font(Typography.stampDate).tracking(1)
            Text(Self.month.string(from: stamp.date).uppercased()).font(Typography.stampDate).tracking(2)
            Text(Self.year.string(from: stamp.date)).font(Typography.stampDate).tracking(1)
            heavyRule
        }
    }

    /// A single date line, optionally boxed by heavy rules (for emblem stamps, so the
    /// emblem sits above a heavy date block as asked).
    @ViewBuilder
    private func dateLine(heavy: Bool) -> some View {
        if heavy {
            VStack(spacing: 2) {
                heavyRule
                Text(Self.shortDate.string(from: stamp.date)).font(Typography.stampDate).tracking(1)
                heavyRule
            }
        } else {
            Text(Self.shortDate.string(from: stamp.date)).font(Typography.stampDate).tracking(1)
        }
    }

    private var heavyRule: some View { Rectangle().frame(width: 46, height: 2) }

    private var isEmblem: Bool { if case .emblem = stamp.center { return true } else { return false } }

    private func fit(aspect: CGFloat, maxWidth: CGFloat, maxHeight: CGFloat) -> CGSize {
        var width = maxWidth
        var height = width / aspect
        if height > maxHeight { height = maxHeight; width = height * aspect }
        return CGSize(width: width, height: height)
    }

    // MARK: - Seeded imperfection

    private var rotation: Angle {
        var rng = SeededGenerator(seed: stamp.id + ".rotation")
        let magnitude = rng.next(in: 2...12)
        return .degrees(rng.next(in: 0...1) < 0.5 ? -magnitude : magnitude)
    }

    private var dashedInner: Bool {
        var rng = SeededGenerator(seed: stamp.id + ".dash")
        return rng.next(in: 0...1) < 0.4
    }

    // MARK: - Landing

    private func land() {
        pressScale = 1.15
        withAnimation(.easeIn(duration: 0.18)) { pressScale = 1 } completion: {
            UIImpactFeedbackGenerator(style: .rigid).impactOccurred()
        }
    }

    // MARK: - Formatting (POSIX — mechanical English regardless of device language)

    private static func courierFormat(_ format: String) -> DateFormatter {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = format
        return formatter
    }
    private static let shortDate = courierFormat("dd MMM yy")
    private static let day = courierFormat("dd")
    private static let month = courierFormat("MMM")
    private static let year = courierFormat("yyyy")
}

/// Paper-coloured notches punched around a postage card's four edges — the stamp
/// perforation. One Canvas pass regardless of how many teeth.
private struct Perforations: View {
    let cardSize: CGSize
    let box: CGSize

    var body: some View {
        Canvas { context, size in
            let origin = CGPoint(x: (size.width - cardSize.width) / 2,
                                 y: (size.height - cardSize.height) / 2)
            let rect = CGRect(origin: origin, size: cardSize)
            let teeth = 2.8, radius = 2.4
            let paper = GraphicsContext.Shading.color(.paper)

            func dot(_ x: CGFloat, _ y: CGFloat) {
                context.fill(Path(ellipseIn: CGRect(x: x - radius, y: y - radius,
                                                    width: radius * 2, height: radius * 2)), with: paper)
            }
            let stepX = cardSize.width / (cardSize.width / (radius * teeth)).rounded()
            var x = rect.minX
            while x <= rect.maxX { dot(x, rect.minY); dot(x, rect.maxY); x += stepX }
            let stepY = cardSize.height / (cardSize.height / (radius * teeth)).rounded()
            var y = rect.minY
            while y <= rect.maxY { dot(rect.minX, y); dot(rect.maxX, y); y += stepY }
        }
        .frame(width: box.width, height: box.height)
        .allowsHitTesting(false)
    }
}

#Preview {
    ScrollView {
        VStack(spacing: 24) {
            ForEach(LabStamp.detailRail) { stamp in
                LabStampView(stamp: stamp, height: 160)
                    .frame(height: 176)
            }
        }
        .frame(maxWidth: .infinity).padding()
    }
    .paperBackground()
}
