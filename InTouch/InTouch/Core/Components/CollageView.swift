//
//  CollageView.swift
//  InTouch
//
//  Renders a Collage, read-only. The editor is a later phase.
//
//  Everything is driven off the live pixel size from GeometryReader: an item's
//  centre is `position × size`, its width is `scale × width`, and even collage text
//  is sized as a fraction of the width. That's what makes a collage look identical
//  on a mini and a Max — nothing here is an absolute point. See Collage.swift.
//
//  The frame is clipped, so cut-outs can be positioned to bleed off the edge the
//  way a real pasted photo overhangs the page.
//

import SwiftUI

struct CollageView: View {

    let collage: Collage

    var body: some View {
        GeometryReader { proxy in
            let size = proxy.size
            ZStack {
                collage.background.fill

                ForEach(collage.items.sorted { $0.zIndex < $1.zIndex }) { item in
                    itemView(item, width: size.width)
                        .rotationEffect(.degrees(item.rotation))
                        .position(
                            x: item.position.x * size.width,
                            y: item.position.y * size.height
                        )
                        .zIndex(item.zIndex)
                }
            }
            .frame(width: size.width, height: size.height)
        }
        .aspectRatio(collage.aspectRatio, contentMode: .fit)
        .clipped()
    }

    // MARK: - Items

    @ViewBuilder
    private func itemView(_ item: CollageItem, width: CGFloat) -> some View {
        let w = item.scale * width
        switch item.content {
        case .photo(let tone): photo(tone, width: w)
        case .sticker(let sticker): stickerView(sticker, id: item.id, width: w)
        case .text(let string): scrap(string, id: item.id, width: width, scale: item.scale)
        case .tape: tape(width: w)
        }
    }

    /// A pasted print: duotone block, a paper edge, a soft drop shadow.
    private func photo(_ tone: FeedPost.Tone, width: CGFloat) -> some View {
        LinearGradient(colors: tone.colours, startPoint: .topLeading, endPoint: .bottomTrailing)
            .frame(width: width, height: width * 1.12)
            .overlay {
                Image(systemName: tone.symbol)
                    .resizable().scaledToFit()
                    .frame(width: width * 0.3)
                    .foregroundStyle(Color.paper.opacity(0.4))
            }
            .overlay(Rectangle().strokeBorder(Color.paper, lineWidth: width * 0.045))
            .shadow(color: Color.text.opacity(0.3), radius: width * 0.02, x: 0, y: width * 0.02)
    }

    @ViewBuilder
    private func stickerView(_ sticker: CollageItem.Sticker, id: String, width: CGFloat) -> some View {
        let colour = seededColour(id)
        switch sticker {
        case .badge(let word):
            Text(word)
                .font(Typography.display(width * 0.2, .bold))
                .foregroundStyle(Color.paper)
                .padding(.horizontal, width * 0.16)
                .padding(.vertical, width * 0.1)
                .background(Capsule().fill(colour))
        case .star:
            Image(systemName: "star.fill")
                .resizable().scaledToFit()
                .frame(width: width)
                .foregroundStyle(colour)
        case .heart:
            Image(systemName: "heart.fill")
                .resizable().scaledToFit()
                .frame(width: width)
                .foregroundStyle(colour)
        case .ring:
            StampRing(seed: id, inset: width * 0.03)
                .stroke(colour, lineWidth: width * 0.035)
                .frame(width: width, height: width)
        }
    }

    /// A torn scrap of handwriting. Size is a fraction of the whole collage width,
    /// so the hand stays proportional on every device.
    private func scrap(_ string: String, id: String, width: CGFloat, scale: CGFloat) -> some View {
        Text(string)
            .font(Typography.collage(scale * width))
            .multilineTextAlignment(.center)
            .foregroundStyle(seededColour(id))
            .fixedSize()
    }

    /// A strip of translucent tape.
    private func tape(width: CGFloat) -> some View {
        Rectangle()
            .fill(Color.aged.opacity(0.5))
            .frame(width: width, height: width * 0.32)
            .overlay(Rectangle().stroke(Color.muted.opacity(0.35), lineWidth: 0.5))
    }

    /// A stable palette colour for a scrap, seeded from its id so it never jumps.
    private func seededColour(_ id: String) -> Color {
        let palette: [Color] = [.ink, .live, .night, .water, .text]
        var rng = SeededGenerator(seed: id + ".colour")
        let index = Int(rng.next(in: 0...Double(palette.count) - 0.001))
        return palette[index]
    }
}

#Preview {
    CollageView(collage: MockData.currentUserCollage)
        .padding(24)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .paperBackground()
}
