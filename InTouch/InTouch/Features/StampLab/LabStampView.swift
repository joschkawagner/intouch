//
//  LabStampView.swift
//  InTouch
//
//  ⚠️ TEMPORARY — StampLab design lab. Safe to delete with the folder.
//
//  Renders ONE lab stamp end to end. Like the shipping StampView it draws into a
//  fixed canonical box and then `.scaleEffect`-scales to the requested height, so
//  proportions hold identically whether a stamp is tiny on the scattered page or
//  large in the detail rail. The canonical box is `200 × (200 · aspect)`, so an
//  oval box is wide, a rectangle box is a landscape card, etc.
//
//  Four layouts, chosen by whether there's a photo and how the shape sets text:
//    • postage    — photo card, perforated edge, caption strip   (photo, boxy)
//    • ink-frame  — photo clipped inside the shape, city in the margin (photo)
//    • arc ink    — a round seal: city over the top, country under (no photo)
//    • straight ink — a boxy stamp: stacked lines               (no photo)
//  Then the double rule and the seeded ink wear go on top of all of them.
//

import SwiftUI

struct LabStampView: View {

    let stamp: LabStamp
    /// Rendered height in points; width follows the shape's aspect.
    var height: CGFloat = 200
    /// Replays the press-down landing on tap (with a rigid haptic), like the real stamp.
    var landsOnTap: Bool = false

    @State private var pressScale: CGFloat = 1

    /// Canonical design height. Every number below is authored in this space.
    private static let canonical: CGFloat = 200
    private static let outerInset: CGFloat = 6
    private static let innerInset: CGFloat = 13

    private var aspect: CGFloat { stamp.shape.aspect }
    private var boxWidth: CGFloat { Self.canonical * aspect }
    private var ink: Color { stamp.ink.color }
    private var marks: LabStampMarks { LabStampMarks(seed: stamp.id) }
    private var wear: Double { stamp.wear ?? seededWear }

    var body: some View {
        face
            .frame(width: boxWidth, height: Self.canonical)
            .scaleEffect(height / Self.canonical)
            .frame(width: height * aspect, height: height)
            .rotationEffect(rotation)
            .scaleEffect(pressScale)
            .accessibilityElement(children: .ignore)
            .accessibilityLabel("\(stamp.city), \(Self.dateFormatter.string(from: stamp.date)), \(stamp.shape.rawValue)")
            .onTapGesture { if landsOnTap { land() } }
    }

    // MARK: - Assembly

    private var face: some View {
        ZStack {
            body(for: stamp)
            if stamp.frameStyle != .postage || !stamp.hasPhoto {
                borders
            }
        }
        .frame(width: boxWidth, height: Self.canonical)
        .foregroundStyle(ink)
        .inkWear(seed: stamp.id, shape: stamp.shape, inset: Self.outerInset, strength: wear)
    }

    @ViewBuilder
    private func body(for stamp: LabStamp) -> some View {
        if stamp.hasPhoto {
            switch stamp.frameStyle {
            case .postage:   postageBody
            case .inkFrame:  inkFrameBody
            }
        } else if stamp.shape.textLayout == .arc {
            arcInkBody
        } else {
            straightInkBody
        }
    }

    /// Outer + inner rule. The inner is thinner and sometimes dashed — most real
    /// stamps carry a double border, occasionally a dashed one.
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
                    .saturation(0.95)
                    .overlay(ink.opacity(0.04))
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
                Text(stamp.city.uppercased())
                    .font(Typography.stampDate).tracking(1)
                Text(stamp.country.uppercased())
                    .font(Typography.stampMark).tracking(1).opacity(0.75)
            }
            Spacer(minLength: 2)
            VStack(alignment: .trailing, spacing: 1) {
                Text(Self.dateFormatter.string(from: stamp.date))
                    .font(Typography.stampMark)
                Image(systemName: marks.landmark)
                    .resizable().scaledToFit().frame(height: 12).opacity(0.8)
            }
        }
        .minimumScaleFactor(0.6)
        .lineLimit(1)
        .padding(.horizontal, 8)
    }

    // MARK: - Layout 2: ink-frame (photo clipped inside the shape)

    @ViewBuilder
    private var inkFrameBody: some View {
        if stamp.shape.textLayout == .arc {
            ZStack {
                photoWell(inset: 40, aged: true)
                LabArcText(text: stamp.city.uppercased(), radius: 78, edge: .top)
                LabArcText(text: stamp.country.uppercased(), radius: 78, edge: .bottom,
                           uiFont: Typography.stampMarkUIFont)
                Text(Self.dateFormatter.string(from: stamp.date))
                    .font(Typography.stampMark).tracking(1)
                    .padding(.horizontal, 5).padding(.vertical, 1)
                    .background(Color.paper.opacity(0.85))
                    .offset(y: Self.canonical * 0.28)
            }
        } else {
            ZStack(alignment: .bottom) {
                photoWell(inset: 9, aged: true)
                VStack(spacing: 0) {
                    Text(stamp.city.uppercased())
                        .font(Typography.stampDate).tracking(1.5)
                    Text(Self.dateFormatter.string(from: stamp.date))
                        .font(Typography.stampMark).tracking(1)
                }
                .foregroundStyle(Color.paper)
                .padding(.vertical, 5)
                .frame(maxWidth: .infinity)
                .background(ink.opacity(0.62))
                .padding(.horizontal, Self.innerInset + 2)
                .padding(.bottom, Self.innerInset + 2)
            }
        }
    }

    /// A photo cropped to the stamp shape, gently aged so it reads as printed in.
    private func photoWell(inset: CGFloat, aged: Bool) -> some View {
        Image(stamp.photo!)
            .resizable().scaledToFill()
            .frame(width: boxWidth - inset * 2, height: Self.canonical - inset * 2)
            .clipShape(StampOutline(shape: stamp.shape))
            .saturation(aged ? 0.72 : 0.95)
            .overlay(StampOutline(shape: stamp.shape).fill(ink.opacity(aged ? 0.14 : 0.04)))
    }

    // MARK: - Layout 3: arc ink (round seal, no photo)

    private var arcInkBody: some View {
        ZStack {
            LabArcText(text: stamp.city.uppercased(), radius: 78, edge: .top)
            LabArcText(text: stamp.country.uppercased(), radius: 78, edge: .bottom,
                       uiFont: Typography.stampMarkUIFont)
            VStack(spacing: 3) {
                Image(systemName: marks.landmark)
                    .resizable().scaledToFit().frame(height: 22)
                Text(Self.dateFormatter.string(from: stamp.date))
                    .font(Typography.stampDate).tracking(1)
                Rectangle().frame(width: 40, height: 0.75).opacity(0.6)
                Text(stamp.word ?? marks.word)
                    .font(Typography.stampMark).tracking(1.4).opacity(0.85)
                StarRow(count: marks.stars).opacity(0.8)
            }
        }
    }

    // MARK: - Layout 4: straight ink (boxy stamp, no photo)

    private var straightInkBody: some View {
        VStack(spacing: 2) {
            HStack(spacing: 6) {
                if marks.showsPlane { Image(systemName: "airplane").resizable().scaledToFit().frame(height: 9) }
                Text(marks.code).font(Typography.stampMark)
                if let arrow = marks.arrow { Image(systemName: arrow).resizable().scaledToFit().frame(height: 8) }
            }
            .opacity(0.7)

            Text(stamp.city.uppercased())
                .font(Typography.stampDate).tracking(1.5)
                .minimumScaleFactor(0.5).lineLimit(1)
            Text(stamp.country.uppercased())
                .font(Typography.stampMark).tracking(1).opacity(0.75)

            HStack(spacing: 5) {
                Rectangle().frame(width: 16, height: 0.75)
                Image(systemName: marks.landmark).resizable().scaledToFit().frame(height: 12)
                Rectangle().frame(width: 16, height: 0.75)
            }
            .opacity(0.7)

            Text(Self.dateFormatter.string(from: stamp.date))
                .font(Typography.stampDate).tracking(1)
            Text(stamp.word ?? marks.word)
                .font(Typography.stampMark).tracking(1.3).opacity(0.85)
        }
        .minimumScaleFactor(0.6)
        .padding(.horizontal, Self.innerInset + 4)
        // Triangle and house crowd their top; nudge the text into the wide part.
        .padding(.top, topBias)
    }

    private var topBias: CGFloat {
        switch stamp.shape {
        case .triangle: 28
        case .house: 14
        default: 0
        }
    }

    // MARK: - Seeded imperfection

    /// Wider than the shipping stamp's 3–8°: a scattered page has more spread.
    private var rotation: Angle {
        var rng = SeededGenerator(seed: stamp.id + ".rotation")
        let magnitude = rng.next(in: 2...13)
        return .degrees(rng.next(in: 0...1) < 0.5 ? -magnitude : magnitude)
    }

    private var seededWear: Double {
        var rng = SeededGenerator(seed: stamp.id + ".wearAmount")
        return rng.next(in: 0.2...0.5)
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

    /// POSIX locale keeps stamps in mechanical English regardless of device language.
    private static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "dd MMM yy"
        return formatter
    }()
}

/// Paper-coloured notches punched around a postage card's four edges — the stamp
/// perforation. Drawn as a Canvas so it's one pass regardless of how many teeth.
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
    VStack(spacing: 30) {
        HStack(spacing: 24) {
            LabStampView(stamp: LabStamp.detailRail[0], height: 150)
            LabStampView(stamp: LabStamp.detailRail[1], height: 150)
        }
        HStack(spacing: 24) {
            LabStampView(stamp: LabStamp.detailRail[2], height: 150)
            LabStampView(stamp: LabStamp.detailRail[3], height: 150)
        }
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .paperBackground()
}
