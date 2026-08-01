//
//  PassportBookView.swift
//  InTouch
//
//  The passport tab's home. The book floats on a muted resting surface (design
//  1c/2a): portrait shows the closed cover; rotating the phone to landscape
//  swings the cover open into a two-page spread you leaf through, and rotating
//  back closes it.
//
//  The app is portrait-locked (see project build settings), so the interface
//  never rotates. `DeviceOrientationModel` reads the physical orientation, and
//  the open book is counter-rotated to fill the screen so it reads upright while
//  the phone is held in landscape.
//
//  Spread 0: identity | the map (the index of everywhere you've been).
//  Spread 1…N: one per city — a label | its auto-composed photo collage.
//  Final spread: the colophon | the back cover (inside-back for now).
//

import SwiftUI

struct PassportBookView: View {

    /// Whose book this is — the name on the cover, the identity page and the
    /// colophon. NO DEFAULT: see `PassportCoverView`'s header for what a
    /// defaulted holder costs.
    let holder: UserProfile

    /// What is inside it. Also no default, for the same reason — a book that
    /// falls back to my cities when handed someone else's holder is worse than
    /// one that refuses to compile.
    let contents: PassportContents

    @State private var orientation = DeviceOrientationModel()
    @State private var clock = PassportTimeOfDay()
    @State private var spreadIndex = 0

    private var mode: PassportRenderMode {
        #if DEBUG
        if let forced = DebugUV.shared.forced { return forced }
        #endif
        return clock.renderMode
    }

    private var cities: [PassportCity] { contents.cities }

    /// identity+map, one per city, then colophon + back cover.
    private var spreadCount: Int { cities.count + 2 }
    private var isOpen: Bool { orientation.isLandscape }

    private var pageRatio: CGFloat { PassportMetrics.referenceSize.width / PassportMetrics.referenceSize.height }
    private var spreadRatio: CGFloat { 2 * pageRatio }

    var body: some View {
        GeometryReader { geo in
            ZStack {
                PassportRestingSurface()
                    .ignoresSafeArea()

                if isOpen {
                    // `geo.size` excludes the safe-area insets, so the floating
                    // spread never slides under the notch or the tab bar.
                    openBook(safeSize: geo.size)
                }

                // The closed cover floats on the surface and swings open on its
                // leading edge — a door hinge — then hides so it doesn't linger
                // edge-on over the spread.
                coverCard(in: geo.size)
                    .rotation3DEffect(
                        .degrees(isOpen ? -105 : 0),
                        axis: (x: 0, y: 1, z: 0),
                        anchor: .leading,
                        perspective: 0.6
                    )
                    .opacity(isOpen ? 0 : 1)
                    .allowsHitTesting(!isOpen)
            }
            .animation(.easeInOut(duration: 0.55), value: isOpen)
            .environment(\.passportRenderMode, mode)   // day / after-dark, down to every page
        }
        // While the book is open, clear the system chrome so the spread reads as
        // a full landscape sheet (the app stays portrait-locked).
        .toolbar(isOpen ? .hidden : .visible, for: .tabBar)
        .statusBarHidden(isOpen)
        .persistentSystemOverlays(isOpen ? .hidden : .automatic)
        .onAppear { orientation.start(); clock.start() }
        .onDisappear { orientation.stop(); clock.stop() }
        .onChange(of: isOpen) { _, open in
            if !open { spreadIndex = 0 }   // closing always returns to the cover / first spread
        }
    }

    // MARK: - Closed cover (floating card)

    private func coverCard(in safe: CGSize) -> some View {
        let size = PassportBookGeometry.fitted(ratio: pageRatio, in: safe)
        let ref = PassportMetrics.referenceSize
        return PassportCoverView(user: holder)
            .frame(width: ref.width, height: ref.height)
            .scaleEffect(size.width / ref.width, anchor: .center)
            .frame(width: size.width, height: size.height)
            .clipShape(RoundedRectangle(cornerRadius: 8))
            .shadow(color: Color.text.opacity(0.32), radius: 12, y: 10)
    }

    // MARK: - Open book (floating spread)

    /// The spread, laid out at landscape dimensions then counter-rotated to fill
    /// the portrait-locked screen, so it reads upright in the hand. `safeSize` is
    /// the portrait content size *inside* the safe area; we swap its dimensions
    /// for the landscape layout, then float one spread-sized window on it.
    private func openBook(safeSize: CGSize) -> some View {
        let landscape = CGSize(width: safeSize.height, height: safeSize.width)
        let spread = PassportBookGeometry.fitted(ratio: spreadRatio, in: landscape)

        return ZStack {
            // The leaf-through strip, windowed to a single floating spread.
            HStack(spacing: 0) {
                ForEach(0..<spreadCount, id: \.self) { index in
                    spreadView(index)
                        .frame(width: spread.width, height: spread.height)
                }
            }
            .frame(width: spread.width, height: spread.height, alignment: .leading)
            .offset(x: -CGFloat(spreadIndex) * spread.width)
            .frame(width: spread.width, height: spread.height, alignment: .leading)
            .clipped()
            .shadow(color: Color.text.opacity(0.32), radius: 13, y: 11)
            .animation(.easeInOut(duration: 0.3), value: spreadIndex)

            PassportPagingControls(mode: mode,
                                   spreadIndex: $spreadIndex,
                                   spreadCount: spreadCount)
                .frame(width: spread.width, height: spread.height)
        }
        .frame(width: landscape.width, height: landscape.height)   // centre on the surface
        .rotationEffect(orientation.contentRotation)
        .frame(width: safeSize.width, height: safeSize.height)
    }

    @ViewBuilder
    private func spreadView(_ index: Int) -> some View {
        if index == 0 {
            spread(
                left: { PassportIdentityPage(user: holder) },
                right: { PassportMapLens(cities: cities) }   // owns its own mode-aware ground
            )
        } else if index <= cities.count {
            let city = cities[index - 1]
            spread(
                left: { PassportCityPage(city: city, date: contents.latestDate(for: city)) },
                right: { PassportCollageView(photoCount: contents.photoCount(for: city),
                                             seed: city.name + "/collage") }
            )
        } else {
            // Final leaf: the colophon | the back cover. The right page is the
            // oxblood cover — the same red the spine is drawn in — so the spine's
            // crease is suppressed here (see `spine`).
            spread(bordersCover: true,
                left: {
                    PassportColophonPage(
                        user: holder,
                        cityCount: contents.cityCount,
                        photoCount: contents.totalPhotoCount
                    )
                },
                right: { PassportBackCoverView() }
            )
        }
    }

    private func spread<L: View, R: View>(
        bordersCover: Bool = false,
        @ViewBuilder left: () -> L,
        @ViewBuilder right: () -> R
    ) -> some View {
        HStack(spacing: 0) {
            left()
            spine(bordersCover: bordersCover)
            right()
        }
    }

    /// The gutter between the two pages — a struck centre line with a faint
    /// shadow, so the spread reads as one bound sheet.
    ///
    /// The gradient is drawn in `ink` (the oxblood cover colour). When the right
    /// page is itself the oxblood cover (`bordersCover`), the red half merges into
    /// the cover and the centred crease is orphaned into an apparently continuous
    /// red field — reading as a stray vertical line, not a gutter. So the crease
    /// is dropped in that case; the soft gradient stays as the binding shadow.
    ///
    /// After dark oxblood vanishes on `uvGround`, so the binding shadow is
    /// struck in black and the crease in faint lit paper — same geometry,
    /// night lighting.
    private func spine(bordersCover: Bool) -> some View {
        LinearGradient(
            colors: mode.isUV
                ? [Color.uvShadow.opacity(0.45), Color.uvShadow.opacity(0.15), Color.uvShadow.opacity(0.45)]
                : [Color.ink.opacity(0.25), Color.ink.opacity(0.06), Color.ink.opacity(0.25)],
            startPoint: .leading, endPoint: .trailing
        )
        .frame(width: 12)
        .overlay {
            if !bordersCover {
                Rectangle()
                    .fill(mode.isUV ? Color.paper.opacity(0.15) : Color.muted.opacity(0.5))
                    .frame(width: 1)
            }
        }
    }

}

#Preview {
    PassportBookView(holder: MockData.currentUser, contents: .currentUser)
}
