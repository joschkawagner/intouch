//
//  PassportPage.swift
//  InTouch
//
//  The substrate every paper page of the passport is authored on.
//
//  The design (Passport Cover Directions) draws every page on one fixed
//  reference page — ID-3 proportions, 88×125mm ≈ 1:1.42, i.e. 232×330 points.
//  The interior content is coordinate-heavy (security printing, the collage
//  grid, the colophon rules), and re-deriving all of it proportionally per
//  device is fragile. So instead, a page's content is laid out once at the
//  reference size and this container scales that reference to fill whatever page
//  frame the open book hands it. Every design measurement then maps 1:1 to a
//  point in the reference space, and every page shares one coordinate system
//  with the security-printing layer drawn beneath it.
//
//  The exception is the map page (`PassportMapLens`): a live MapKit view can't
//  be scale-effected without going fuzzy or losing interaction, so it stays a
//  native view sized to the page and does not use this container.
//
//  `PassportPage` also owns the page *ground* — paper in daylight, and (from the
//  UV phase) the after-dark ground — so switching the whole booklet's ground is
//  a change in one place.
//

import SwiftUI

/// The passport's fixed authoring geometry, kept non-generic so it can be read
/// without spelling out `PassportPage`'s content type (e.g. from the security
/// layer). The reference page is ID-3 proportioned — 88×125mm ≈ 1:1.42.
enum PassportMetrics {
    static let referenceSize = CGSize(width: 232, height: 330)
}

struct PassportPage<Content: View>: View {

    /// The reference page the design is authored on. All page content is written
    /// in these units, then scaled to fit.
    static var referenceSize: CGSize { PassportMetrics.referenceSize }

    /// Optional security-printing level, drawn full-page beneath the content
    /// (so its frame and microprint reach the page edges, under the padded
    /// fields). `nil` leaves the page plain.
    private let security: SecurityPrinting.Level?
    private let content: Content

    init(security: SecurityPrinting.Level? = nil,
         @ViewBuilder content: () -> Content) {
        self.security = security
        self.content = content()
    }

    var body: some View {
        GeometryReader { geo in
            let ref = Self.referenceSize
            let scale = min(geo.size.width / ref.width, geo.size.height / ref.height)

            ZStack {
                if let security {
                    SecurityPrinting(level: security)
                }
                content
            }
            .frame(width: ref.width, height: ref.height, alignment: .topLeading)
            .scaleEffect(scale, anchor: .center)
            .frame(width: geo.size.width, height: geo.size.height)
        }
        .background(Color.paper)   // the page ground; the UV phase swaps this
        .clipped()
    }
}

extension View {
    /// Pins this view's top-left corner to (`x`, `y`) in the reference page
    /// space, the way the design specifies field positions. Use inside a
    /// `PassportPage`'s content (a ZStack), where every field is placed by its
    /// design coordinate rather than stacked.
    func referenceOrigin(x: CGFloat, y: CGFloat) -> some View {
        frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
            .offset(x: x, y: y)
    }
}

#Preview {
    PassportPage {
        Text(Typography.chrome("passport"))
            .font(Typography.passportWordmark)
            .foregroundStyle(Color.ink)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    .frame(width: 232, height: 330)
}
