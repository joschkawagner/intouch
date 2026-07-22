//
//  PhotoCarouselView.swift
//  InTouch
//
//  The photo area of a feed card. One photo renders full-bleed with no dots; two or
//  more become an Instagram-style paged carousel — horizontal swipe, page dots.
//
//  Framing is a fixed 4:5 portrait (`aspect`) applied identically to a single photo
//  and to every carousel page, so the feed keeps one rhythm regardless of how many
//  photos a post has or what shape they are. `scaledToFill` + `clipped` crops any
//  source aspect into that frame.
//
//  Lives in Features/Friends because only the friends feed uses it today. If Groups
//  or Events render the same carousel, it moves to Core/Components/.
//

import SwiftUI

struct PhotoCarouselView: View {

    /// Asset-catalogue image names, in order. Expected to be non-empty.
    let photos: [String]

    /// The page currently centred — drives both the pager and which dot is filled.
    @State private var selection = 0

    /// Portrait card, width : height = 4 : 5.
    private let aspect: CGFloat = 4.0 / 5.0

    var body: some View {
        if photos.count <= 1 {
            photo(photos.first ?? "")
        } else {
            carousel
        }
    }

    // MARK: - Carousel

    private var carousel: some View {
        // Color.clear + aspectRatio establishes a concrete 4:5 box at the card's
        // full width; the GeometryReader then hands the TabView an exact size
        // (a paged TabView has no intrinsic height of its own).
        Color.clear
            .aspectRatio(aspect, contentMode: .fit)
            .overlay {
                GeometryReader { proxy in
                    TabView(selection: $selection) {
                        ForEach(Array(photos.enumerated()), id: \.offset) { index, name in
                            Image(name)
                                .resizable()
                                .scaledToFill()
                                .frame(width: proxy.size.width, height: proxy.size.height)
                                .clipped()
                                .tag(index)
                        }
                    }
                    .tabViewStyle(.page(indexDisplayMode: .never))
                }
            }
            .overlay(alignment: .bottom) { dots }
    }

    /// Page dots in `paper`, the current page solid and the rest faded. They sit on a
    /// small translucent `night` capsule so they stay legible over a bright photo (a
    /// snow field) as well as a dark one — paper dots alone would vanish on white.
    private var dots: some View {
        HStack(spacing: 7) {
            ForEach(photos.indices, id: \.self) { index in
                Circle()
                    .fill(index == selection ? Color.paper : Color.paper.opacity(0.5))
                    .frame(width: 6, height: 6)
            }
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 7)
        .background(Capsule().fill(Color.night.opacity(0.32)))
        .padding(.bottom, 12)
    }

    // MARK: - Single photo

    /// A full-bleed 4:5 photo — the same framing a carousel page uses, no dots.
    private func photo(_ name: String) -> some View {
        Color.clear
            .aspectRatio(aspect, contentMode: .fit)
            .overlay {
                Image(name)
                    .resizable()
                    .scaledToFill()
            }
            .clipped()
    }
}

#Preview("Carousel") {
    PhotoCarouselView(photos: ["ski-1", "ski-2"])
        .paperBackground()
}

#Preview("Single") {
    PhotoCarouselView(photos: ["london"])
        .paperBackground()
}
