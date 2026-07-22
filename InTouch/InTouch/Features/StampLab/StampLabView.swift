//
//  StampLabView.swift
//  InTouch
//
//  ⚠️ TEMPORARY — StampLab design lab. Reached from a #if DEBUG row in Settings.
//  Deleting Features/StampLab and that one row removes the lab entirely; it never
//  touches the shipping StampView or the passport screen.
//
//  Purpose: develop a passport-STAMP vocabulary to judge before wiring anything
//  into the app — many shapes, real ink wear and density, and the common case of a
//  stamp framing a real PHOTO pinned to a city. Two sections:
//    1. a scattered, overlapping passport page (the real target),
//    2. a close-up rail of individual stamps, to inspect the detail.
//
//  Note on layout: the page width is measured ONCE by a GeometryReader wrapping the
//  ScrollView, then handed to the page as a concrete size. A GeometryReader placed
//  *inside* a ScrollView reports the viewport height instead of the content height,
//  which silently stops the ScrollView from scrolling — so it's kept outside.
//

import SwiftUI

struct StampLabView: View {

    /// Taller than wide, like a single passport page.
    private static let pageAspect: CGFloat = 0.72

    var body: some View {
        GeometryReader { proxy in
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    header
                    ScatteredPage(size: pageSize(totalWidth: proxy.size.width))
                        .padding(.horizontal, 12)
                        .padding(.top, 8)
                    detailRail
                    footer
                }
                .padding(.bottom, 40)
            }
            .scrollIndicators(.hidden)
        }
        .paperBackground()
        .navigationBarTitleDisplayMode(.inline)
    }

    private func pageSize(totalWidth: CGFloat) -> CGSize {
        let width = totalWidth - 24        // matches the horizontal padding
        return CGSize(width: width, height: width / Self.pageAspect)
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("TEMPORARY · DESIGN LAB")
                .font(Typography.stampMark).tracking(2).foregroundStyle(Color.muted)
            Text(Typography.chrome("Stamp Lab"))
                .font(Typography.masthead).foregroundStyle(Color.ink)
            Text("Every stamp is a photo pinned to a city. Shape, wear and density — not colour.")
                .font(Typography.bodySmall).foregroundStyle(Color.text)
        }
        .padding(.horizontal, 20)
        .padding(.top, 8)
        .padding(.bottom, 14)
    }

    private var detailRail: some View {
        VStack(alignment: .leading, spacing: 22) {
            Text(Typography.chrome("Close up"))
                .font(Typography.label).tracking(1).foregroundStyle(Color.muted)
                .padding(.horizontal, 20)

            railItem(LabStamp.detailRail[0], note: "postage · photo card")
            railItem(LabStamp.detailRail[1], note: "ink-frame · photo in a scallop")
            railItem(LabStamp.detailRail[2], note: "heavy wear · faded, broken edges")
            railItem(LabStamp.detailRail[3], note: "crisp · full detail")
        }
        .padding(.top, 30)
    }

    /// One close-up: a large stamp on the left, its note on the right. Laid out in a
    /// vertical column so every close-up is reachable by the vertical scroll.
    private func railItem(_ stamp: LabStamp, note: String) -> some View {
        HStack(spacing: 18) {
            LabStampView(stamp: stamp, height: 150, landsOnTap: true)
                .frame(width: 190, height: 168)
            Text(note)
                .font(Typography.bodySmall).foregroundStyle(Color.text)
                .fixedSize(horizontal: false, vertical: true)
            Spacer(minLength: 0)
        }
        .padding(.horizontal, 20)
    }

    private var footer: some View {
        Text("TAP A CLOSE-UP TO STRIKE IT")
            .font(Typography.label).tracking(Typography.stampTracking)
            .foregroundStyle(Color.muted)
            .frame(maxWidth: .infinity)
            .padding(.top, 26)
    }
}

/// The scattered, overlapping page. Positions are 0…1 fractions of the page box
/// (see LabStamp.page), so it composes the same at any size; `.clipped()` lets edge
/// stamps crop like a real well-travelled page. Newest (`z`) sits on top.
private struct ScatteredPage: View {

    let size: CGSize

    var body: some View {
        ZStack {
            Color.paper
            PrintedGuides()
            pageNumbers

            ForEach(LabStamp.page) { placement in
                LabStampView(stamp: placement.stamp, height: placement.scale * size.height)
                    .position(x: placement.position.x * size.width,
                              y: placement.position.y * size.height)
                    .zIndex(placement.z)
            }
        }
        .frame(width: size.width, height: size.height)
        .clipped()
        .overlay(Rectangle().stroke(Color.muted.opacity(0.45), lineWidth: 1))
        .shadow(color: Color.text.opacity(0.15), radius: 10, x: 0, y: 5)
    }

    /// Faint printed page numbers in the top corners, the way a passport page is
    /// pre-numbered before anything lands on it.
    private var pageNumbers: some View {
        ZStack {
            Text("10").position(x: 26, y: 22)
            Text("11").position(x: size.width - 26, y: 22)
        }
        .font(Typography.stampDate)
        .foregroundStyle(Color.muted.opacity(0.5))
    }
}

#Preview {
    NavigationStack { StampLabView() }
}
