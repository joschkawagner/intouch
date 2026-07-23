//
//  PassportBookView.swift
//  InTouch
//
//  The passport tab's home. Portrait shows the closed cover; rotating the phone
//  to landscape swings the cover open into a two-page spread you leaf through,
//  and rotating back closes it.
//
//  The app is portrait-locked (see project build settings), so the interface
//  never rotates. `DeviceOrientationModel` reads the physical orientation, and
//  the open book is counter-rotated to fill the screen so it reads upright while
//  the phone is held in landscape.
//
//  Spread 0: identity | the map (the index of everywhere you've been).
//  Spread 1…N: one per city — a label | a solid Bauhaus block (collage later).
//

import SwiftUI

struct PassportBookView: View {

    @State private var orientation = DeviceOrientationModel()
    @State private var spreadIndex = 0

    private let cities = MockData.cities
    private var spreadCount: Int { cities.count + 1 }
    private var isOpen: Bool { orientation.isLandscape }

    var body: some View {
        GeometryReader { geo in
            ZStack {
                Color.ink.ignoresSafeArea()

                if isOpen {
                    // `geo.size` here excludes the safe-area insets (status bar,
                    // home indicator, tab bar), so the spread never slides under
                    // the notch or the tab bar once it's counter-rotated.
                    openBook(safeSize: geo.size)
                }

                // The cover sits on top and swings open on its leading edge —
                // a door hinge — revealing the spread beneath, then hides so it
                // doesn't linger edge-on. Full-bleed, so it ignores the safe area.
                PassportCoverView()
                    .rotation3DEffect(
                        .degrees(isOpen ? -105 : 0),
                        axis: (x: 0, y: 1, z: 0),
                        anchor: .leading,
                        perspective: 0.6
                    )
                    .opacity(isOpen ? 0 : 1)
                    .allowsHitTesting(!isOpen)
                    .ignoresSafeArea()
            }
            .animation(.easeInOut(duration: 0.55), value: isOpen)
        }
        // While the book is open, clear the system chrome so the spread reads as
        // a full landscape sheet — otherwise the tab bar / status bar / home
        // indicator sit sideways along the edges (the app stays portrait-locked).
        .toolbar(isOpen ? .hidden : .visible, for: .tabBar)
        .statusBarHidden(isOpen)
        .persistentSystemOverlays(isOpen ? .hidden : .automatic)
        .onAppear { orientation.start() }
        .onDisappear { orientation.stop() }
        .onChange(of: isOpen) { _, open in
            if !open { spreadIndex = 0 }   // closing always returns to the cover / first spread
        }
    }

    // MARK: - Open book

    /// The spread, laid out at landscape dimensions then counter-rotated to fill
    /// the portrait-locked screen, so it reads upright in the hand. `safeSize` is
    /// the portrait content size *inside* the safe area; we swap its dimensions
    /// for the landscape layout.
    private func openBook(safeSize: CGSize) -> some View {
        let landscape = CGSize(width: safeSize.height, height: safeSize.width)
        return ZStack {
            HStack(spacing: 0) {
                ForEach(0..<spreadCount, id: \.self) { index in
                    spreadView(index)
                        .frame(width: landscape.width, height: landscape.height)
                }
            }
            .frame(width: landscape.width, height: landscape.height, alignment: .leading)
            .offset(x: -CGFloat(spreadIndex) * landscape.width)

            pagingControls
        }
        .frame(width: landscape.width, height: landscape.height)
        .clipped()
        .rotationEffect(orientation.contentRotation)
        .frame(width: safeSize.width, height: safeSize.height)
        .animation(.easeInOut(duration: 0.3), value: spreadIndex)
    }

    @ViewBuilder
    private func spreadView(_ index: Int) -> some View {
        if index == 0 {
            spread(
                left: { PassportIdentityPage(user: MockData.currentUser) },
                right: { PassportMapLens(cities: cities).paperBackground() }
            )
        } else {
            let city = cities[index - 1]
            spread(
                left: { PassportCityPage(city: city, date: latestDate(for: city)) },
                right: { PassportColourBlock(city: city) }
            )
        }
    }

    private func spread<L: View, R: View>(
        @ViewBuilder left: () -> L,
        @ViewBuilder right: () -> R
    ) -> some View {
        HStack(spacing: 0) {
            left()
            spine
            right()
        }
    }

    /// The gutter between the two pages — a struck centre line with a faint
    /// shadow, so the spread reads as one bound sheet.
    private var spine: some View {
        LinearGradient(
            colors: [Color.ink.opacity(0.25), Color.ink.opacity(0.06), Color.ink.opacity(0.25)],
            startPoint: .leading, endPoint: .trailing
        )
        .frame(width: 12)
        .overlay(Rectangle().fill(Color.muted.opacity(0.5)).frame(width: 1))
    }

    // MARK: - Paging (tap the page edges — kept simple, no page-curl)

    private var pagingControls: some View {
        HStack(spacing: 0) {
            edgeTap(systemImage: "chevron.left", enabled: spreadIndex > 0) {
                if spreadIndex > 0 { spreadIndex -= 1 }
            }
            Spacer()
            edgeTap(systemImage: "chevron.right", enabled: spreadIndex < spreadCount - 1) {
                if spreadIndex < spreadCount - 1 { spreadIndex += 1 }
            }
        }
    }

    private func edgeTap(systemImage: String, enabled: Bool, action: @escaping () -> Void) -> some View {
        Image(systemName: systemImage)
            .font(Typography.body)
            .foregroundStyle(Color.ink.opacity(enabled ? 0.35 : 0))
            .frame(width: 72)
            .frame(maxHeight: .infinity)
            .contentShape(Rectangle())
            .onTapGesture { if enabled { action() } }
            .allowsHitTesting(enabled)
    }

    // MARK: - Data

    /// The most recent moment recorded in a city (its label date), if any.
    private func latestDate(for city: PassportCity) -> Date? {
        MockData.entries.filter { $0.city == city }.map(\.date).max()
    }
}

#Preview {
    PassportBookView()
}
