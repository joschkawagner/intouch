//
//  IDCardFace.swift
//  InTouch
//
//  The substrate the ID card is authored on — the card's counterpart to
//  PassportPage, deliberately NOT a reuse of it.
//
//  Same principle as the booklet: author once at a fixed reference size, then
//  scale that reference to fill whatever frame the screen hands it, so every
//  design measurement maps 1:1 to a point and the content shares one coordinate
//  system with the security printing beneath it. Different geometry: ID-1
//  landscape rather than ID-3 portrait, and a die-cut corner radius, because a
//  card has edges of its own where a page is a leaf inside something else.
//
//  `IDCardFace` owns the card's ground — paper by day, uvGround after dark —
//  so switching the whole card's ground is a change in one place.
//

import SwiftUI

/// The card's fixed authoring geometry, kept non-generic so it can be read
/// without spelling out `IDCardFace`'s content type (e.g. from the printing
/// layer), exactly as `PassportMetrics` is for the page.
///
/// ID-1 is 85.6 × 54 mm. At 340/54 = 6.2963 pt/mm that is 538.96 pt wide, so
/// 539 × 340 sits 0.04 pt from true across the whole width — under a device
/// pixel at any scale. The same conversion turns ID-1's 3.18 mm corner radius
/// into 20.02 pt, which is why the radius is a round number rather than a guess.
///
/// WHY THIS SIZE AND NOT SMALLER: the card is quarter-turned on screen, so its
/// on-screen HEIGHT is bounded by the portrait screen's WIDTH. With a 24 pt
/// margin that puts the scale between 0.96 (iPhone SE) and 1.15 (Pro Max) —
/// the card is authored essentially 1:1 for the screen it is read on. That
/// matters concretely: the printing primitives are authored in absolute points
/// (MicroprintBand at 4 pt), so at scale ≈ 1 they print at the same physical
/// density as the book's pages. Author the card at, say, 336 × 212 and it
/// renders at 1.6×, at which point 4 pt microprint becomes legible — and
/// legible microprint is not microprint.
enum IDCardMetrics {
    static let referenceSize = CGSize(width: 539, height: 340)
    static let cornerRadius: CGFloat = 20
}

struct IDCardFace<Content: View>: View {

    /// The reference card the design is authored on. All card content is
    /// written in these units, then scaled to fit.
    static var referenceSize: CGSize { IDCardMetrics.referenceSize }

    /// Stable identity for the seeded printing geometry — the same card prints
    /// the same terrain forever, in both modes.
    private let seed: String
    private let content: Content

    @Environment(\.passportRenderMode) private var mode

    init(seed: String = "id-card", @ViewBuilder content: () -> Content) {
        self.seed = seed
        self.content = content()
    }

    var body: some View {
        GeometryReader { geo in
            let ref = Self.referenceSize
            let scale = min(geo.size.width / ref.width, geo.size.height / ref.height)

            ZStack {
                IDCardPrinting(seed: seed)
                content
            }
            .frame(width: ref.width, height: ref.height, alignment: .topLeading)
            // The die-cut is clipped INSIDE the reference space so the radius
            // scales with the card rather than staying a fixed screen radius.
            .clipShape(RoundedRectangle(cornerRadius: IDCardMetrics.cornerRadius,
                                        style: .continuous))
            .scaleEffect(scale, anchor: .center)
            .frame(width: geo.size.width, height: geo.size.height)
        }
        .background(
            RoundedRectangle(cornerRadius: IDCardMetrics.cornerRadius, style: .continuous)
                .fill(mode.isUV ? Color.uvGround : Color.paper)
        )
    }
}

#Preview {
    HStack(spacing: 20) {
        IDCardFace(seed: "preview") { EmptyView() }
            .frame(width: 539, height: 340)
            .environment(\.passportRenderMode, .daylight)

        IDCardFace(seed: "preview") { EmptyView() }
            .frame(width: 539, height: 340)
            .environment(\.passportRenderMode, .uv)
    }
    .padding()
    .background(Color.muted)
}
