//
//  StampView.swift
//  InTouch
//
//  The signature component. See docs/DESIGN.md § The stamp.
//
//  Everything else in the app can be plain if this is right.
//
//  Sizing: the stamp is drawn in a fixed 160pt coordinate space and then scaled
//  to whatever `diameter` you ask for. That means one implementation serves the
//  passport grid today and tiny stamp-shaped map pins later, and the proportions
//  can never drift apart between the two.
//

import SwiftUI
import UIKit

struct StampView: View {

    /// What earned the stamp. Determines the ink colour and the mark.
    enum Kind {
        case person
        case event
        case firstCity

        var ink: Color {
            switch self {
            case .person: .ink
            case .event: .live
            case .firstCity: .night
            }
        }

        var mark: String {
            switch self {
            case .person: "MET"
            case .event: "EVENT"
            case .firstCity: "FIRST ENTRY"
            }
        }
    }

    /// Stable identifier. Seeds every imperfection — rotation, gaps, wobble.
    let id: String
    let city: String
    let date: Date
    let kind: Kind

    /// Rendered size. The stamp is scaled to fit, so proportions always hold.
    var diameter: CGFloat = 150

    /// Overrides the ink colour. `nil` (the default) uses `inkColor`, the muted
    /// per-kind ink the app ships with; a caller can pass a brighter ink to override it.
    var ink: Color? = nil

    /// Replays the press-down landing on tap, with a haptic.
    /// Off by default — a grid of stamps all thumping on appear would be awful.
    var landsOnTap: Bool = false

    @State private var scale: CGFloat = 1

    /// The size the stamp is designed at. All the numbers below are in this space.
    private static let canonicalSize: CGFloat = 160

    var body: some View {
        stampFace
            .frame(width: Self.canonicalSize, height: Self.canonicalSize)
            .scaleEffect(diameter / Self.canonicalSize)
            .frame(width: diameter, height: diameter)
            // Collapse before the effects and the gesture. The city name is drawn
            // one character per Text (see ArcText), so without this VoiceOver
            // reads a stamp as "Z, Ü, R, I, C, H" instead of "Zürich".
            .accessibilityElement(children: .ignore)
            .accessibilityLabel("\(city), \(Self.accessibleDateFormatter.string(from: date)), \(kind.mark)")
            .rotationEffect(rotation)
            .scaleEffect(scale)
            .onTapGesture { if landsOnTap { land() } }
    }

    /// The ink actually struck: the override if given, otherwise the kind's own ink.
    private var inkColor: Color { ink ?? kind.ink }

    private var stampFace: some View {
        ZStack {
            StampRing(seed: id, inset: 5)
                .stroke(inkColor, lineWidth: 2)

            StampRing(seed: id + ".inner", inset: 13)
                .stroke(inkColor.opacity(0.55), lineWidth: 0.75)

            ArcText(text: city.uppercased(), radius: 52)
                .foregroundStyle(inkColor)

            VStack(spacing: 5) {
                Text(Self.stampDateFormatter.string(from: date).uppercased())
                    .font(Typography.stampDate)
                    .tracking(Typography.stampTracking)

                Rectangle()
                    .frame(width: 46, height: 0.75)
                    .opacity(0.6)

                Text(kind.mark)
                    .font(Typography.stampMark)
                    .tracking(Typography.stampTracking)
                    .opacity(0.85)
            }
            .foregroundStyle(inkColor)
            .offset(y: 6)
        }
        // Real ink on absorbent paper is never fully opaque.
        .opacity(0.9)
    }

    // MARK: - Seeded imperfection

    /// 3–8° off axis, direction and amount fixed by the id. DESIGN.md:
    /// "randomised per stamp but stable ... so it never jumps between renders".
    private var rotation: Angle {
        var rng = SeededGenerator(seed: id + ".rotation")
        let magnitude = rng.next(in: 3...8)
        let leansLeft = rng.next(in: 0...1) < 0.5
        return .degrees(leansLeft ? -magnitude : magnitude)
    }

    // MARK: - Landing

    /// Press-down: 1.15 → 1.0, fast, sharp easing, one rigid thump as it lands.
    /// Mechanical, not bouncy — a stamp press, not a spring.
    private func land() {
        scale = 1.15
        withAnimation(.easeIn(duration: 0.18)) {
            scale = 1
        } completion: {
            UIImpactFeedbackGenerator(style: .rigid).impactOccurred()
        }
    }

    // MARK: - Formatting

    /// Static because building a DateFormatter is expensive and this runs per render.
    /// POSIX locale keeps stamps in mechanical English regardless of device language.
    private static let stampDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "dd MMM yy"
        return formatter
    }()

    private static let accessibleDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .none
        return formatter
    }()
}

#Preview {
    VStack(spacing: 24) {
        HStack(spacing: 16) {
            StampView(id: "a", city: "Zürich", date: .now, kind: .person)
            StampView(id: "b", city: "Berlin", date: .now, kind: .event)
        }
        StampView(id: "c", city: "Lisbon", date: .now, kind: .firstCity)
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .paperBackground()
}
