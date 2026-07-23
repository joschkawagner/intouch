//
//  PassportCollageView.swift
//  InTouch
//
//  The right page of a city spread — the auto-composed photo collage (design
//  2c). Picks a template by photo count and fills it: photo cells render as
//  neutral placeholder slots (no photo model yet), empty cells render outline-
//  only (a 1.5px ink border, paper through). Laid out in the 232×330 reference
//  page so the design's cell rects map 1:1.
//
//  This is deliberately the *opposite* of Core/Components/CollageView, the
//  hand-assembled profile collage — here the app composes a Mondrian grid.
//

import SwiftUI

struct PassportCollageView: View {

    let photoCount: Int

    var body: some View {
        PassportPage {
            ZStack {
                let cells = CollageTemplate.cells(photoCount: photoCount)
                ForEach(Array(cells.enumerated()), id: \.offset) { _, cell in
                    cellView(cell)
                        .frame(width: cell.rect.width, height: cell.rect.height)
                        .referenceOrigin(x: cell.rect.minX, y: cell.rect.minY)
                }
            }
        }
    }

    @ViewBuilder
    private func cellView(_ cell: CollageCell) -> some View {
        if cell.isPhoto {
            PassportPhotoSlot()
        } else {
            // Empty cell — outline only, paper showing through (no solid fill).
            Rectangle()
                .strokeBorder(Color.ink, lineWidth: 1.5)
        }
    }
}

/// A stand-in for a photo until the photo model exists: a soft neutral field
/// with a faint photo glyph, so a photo cell reads distinctly from an empty
/// outline cell and from bare paper.
private struct PassportPhotoSlot: View {
    var body: some View {
        ZStack {
            Color.muted.opacity(0.30)
            Image(systemName: "photo")
                .resizable()
                .scaledToFit()
                .frame(width: 22, height: 22)
                .foregroundStyle(Color.text.opacity(0.30))
        }
    }
}

#Preview {
    HStack(spacing: 12) {
        ForEach([1, 3, 6], id: \.self) { n in
            PassportCollageView(photoCount: n)
                .frame(width: 232, height: 330)
        }
    }
    .padding()
    .background(Color.muted)
}
