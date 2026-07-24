#if DEBUG
//
//  PassportDesignLab.swift
//  InTouch
//
//  DEBUG-ONLY, TEMPORARY design-lab gallery for the UV pass — NOT part of the
//  shipped app. Every reference-space page type rendered side by side in a
//  portrait scroll, so daylight and UV can be iterated and compared without
//  rotating the phone per look. Mode comes from the DebugUV chip
//  (CLOCK → DAY → UV); the pages float on the real PassportRestingSurface so
//  each mode is judged against its true ground.
//
//  The map page is deliberately absent: it's a native MapKit view (not
//  reference space) and fights the scroll gesture — it's judged in the real
//  open book instead.
//
//  REMOVE when the UV pass lands:
//    1. delete this file,
//    2. restore PassportView's overlay to the bare DebugUVChip.
//  Then `grep -rn "PassportDesignLab" InTouch/` must be empty.
//

import SwiftUI

struct PassportDesignLab: View {

    @Environment(\.dismiss) private var dismiss
    @State private var clock = PassportTimeOfDay()
    @State private var debug = DebugUV.shared

    private var mode: PassportRenderMode {
        debug.forced ?? clock.renderMode
    }

    var body: some View {
        GeometryReader { geo in
            let ref = PassportMetrics.referenceSize
            let pageWidth = geo.size.width - 32
            let pageHeight = pageWidth * ref.height / ref.width

            ZStack {
                PassportRestingSurface()
                    .ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 28) {
                        Text(Typography.chrome("temporary · design lab"))
                            .font(Typography.label)
                            .tracking(Typography.stampTracking)
                            .foregroundStyle(labelColor)
                            .padding(.top, 56)

                        section("identity", width: pageWidth) {
                            PassportIdentityPage(user: MockData.currentUser)
                                .frame(width: pageWidth, height: pageHeight)
                        }
                        section("city label", width: pageWidth) {
                            PassportCityPage(city: MockData.zurich,
                                             date: MockData.entries.first?.date)
                                .frame(width: pageWidth, height: pageHeight)
                        }
                        section("collage · 1 photo", width: pageWidth) {
                            PassportCollageView(photoCount: 1)
                                .frame(width: pageWidth, height: pageHeight)
                        }
                        section("collage · 6 photos", width: pageWidth) {
                            PassportCollageView(photoCount: 6)
                                .frame(width: pageWidth, height: pageHeight)
                        }
                        section("colophon", width: pageWidth) {
                            PassportColophonPage(user: MockData.currentUser,
                                                 cityCount: 7, photoCount: 29)
                                .frame(width: pageWidth, height: pageHeight)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.bottom, 40)
                }
            }
        }
        .environment(\.passportRenderMode, mode)
        .overlay(alignment: .topTrailing) {
            HStack(spacing: 8) {
                DebugUVChip()
                Button { dismiss() } label: {
                    Text("CLOSE")
                        .font(Typography.timestamp)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 5)
                        .background(Color.night)
                        .foregroundStyle(Color.paper)
                }
            }
            .padding(8)
        }
        .onAppear { clock.start() }
        .onDisappear { clock.stop() }
    }

    /// A gallery row: caption over the page, both centred.
    private func section<Page: View>(_ caption: String, width: CGFloat,
                                     @ViewBuilder page: () -> Page) -> some View {
        VStack(spacing: 8) {
            Text(Typography.chrome(caption))
                .font(Typography.timestamp)
                .foregroundStyle(labelColor)
                .frame(width: width, alignment: .leading)
            page()
                .shadow(color: Color.black.opacity(0.25), radius: 8, y: 5)
        }
    }

    /// Gallery chrome ink — legible on the resting surface in either mode.
    private var labelColor: Color {
        mode.isUV ? Color.paper.opacity(0.6) : Color.text
    }
}

#Preview {
    PassportDesignLab()
}
#endif
