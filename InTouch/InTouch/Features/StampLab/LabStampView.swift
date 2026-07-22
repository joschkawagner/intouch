//
//  LabStampView.swift
//  InTouch
//
//  ⚠️ TEMPORARY — StampLab design lab. Safe to delete with the folder.
//
//  Renders ONE city stamp — ink only, no photos (the new model; see StampLibrary).
//  Like the shipping StampView it draws into a fixed canonical box and then
//  `.scaleEffect`-scales to the requested height, so proportions hold whether a
//  stamp is small on the page or large in the detail rail. Canonical box: 200 ×
//  (200 · aspect).
//
//  Layering, bottom to top:
//    1. InkWash   — the blotchy interior ink tint (realism).
//    2. body      — the landmark (or a neutral star) plus city / country / date.
//    3. borders   — the double rule.
//    4. inkWear   — the seeded distress mask over everything.
//
//  Round shapes arc the city over the top and the country under the bottom; boxy
//  shapes set them on straight lines. The landmark is the dominant central mark.
//

import SwiftUI

struct LabStampView: View {

    let stamp: LabStamp
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
    private var wear: Double { stamp.wear ?? 0.3 }

    var body: some View {
        if landsOnTap {
            scaledFace.onTapGesture { land() }
        } else {
            scaledFace                    // page is display-only: no tap target
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
            .accessibilityLabel("\(stamp.city), \(Self.shortDate.string(from: stamp.date))")
    }

    private var face: some View {
        ZStack {
            InkWash(seed: stamp.id, shape: stamp.shape, ink: ink)
            inkBody
            borders
        }
        .frame(width: boxWidth, height: Self.canonical)
        .foregroundStyle(ink)
        .inkWear(seed: stamp.id, shape: stamp.shape, inset: Self.outerInset, strength: wear)
    }

    @ViewBuilder
    private var inkBody: some View {
        if stamp.shape.textLayout == .arc { arcBody } else { straightBody }
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

    // MARK: - Round seal

    private var arcBody: some View {
        ZStack {
            LabArcText(text: stamp.city.uppercased(), radius: 80, edge: .top)
            LabArcText(text: stamp.country.uppercased(), radius: 80, edge: .bottom,
                       uiFont: Typography.stampMarkUIFont)
            VStack(spacing: 4) {
                centerGraphic(maxWidth: boxWidth * 0.58, maxHeight: Self.canonical * 0.46)
                dateLine
                subtitleLine
            }
        }
    }

    // MARK: - Boxy stamp

    private var straightBody: some View {
        VStack(spacing: 4) {
            Text(stamp.city.uppercased())
                .font(Typography.stampDate).tracking(1.4)
                .minimumScaleFactor(0.5).lineLimit(1)
            centerGraphic(maxWidth: boxWidth * 0.6, maxHeight: Self.canonical * 0.34)
            dateLine
            Text(stamp.country.uppercased())
                .font(Typography.stampMark).tracking(1).opacity(0.72)
                .minimumScaleFactor(0.5).lineLimit(1)
            subtitleLine
        }
        .padding(.horizontal, Self.innerInset + 4)
    }

    // MARK: - Shared pieces

    /// The dominant central mark: the city's landmark, or a neutral star for the
    /// generic (non-library) stamp.
    @ViewBuilder
    private func centerGraphic(maxWidth: CGFloat, maxHeight: CGFloat) -> some View {
        if let landmark = stamp.landmark {
            let size = fit(aspect: landmark.aspect, maxWidth: maxWidth, maxHeight: maxHeight)
            LandmarkShape(landmark: landmark)
                .fill(ink, style: FillStyle(eoFill: landmark.usesEvenOdd))
                .frame(width: size.width, height: size.height)
        } else {
            let side = min(maxWidth, maxHeight) * 0.7
            StarShape().fill(ink).frame(width: side, height: side)
        }
    }

    private var dateLine: some View {
        Text(Self.shortDate.string(from: stamp.date))
            .font(Typography.stampDate).tracking(1)
    }

    @ViewBuilder
    private var subtitleLine: some View {
        if let subtitle = stamp.subtitle {
            Text(subtitle)
                .font(Typography.stampMark).tracking(1.3).opacity(0.72)
                .minimumScaleFactor(0.5).lineLimit(1)
        }
    }

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

    private static let shortDate: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "dd MMM yy"
        return formatter
    }()
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
