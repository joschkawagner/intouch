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
//  After dark (2c·uv): photographs can't fluoresce, so photo cells go dark and
//  non-reactive (`uvCell` with a faint teal edge) while the empty cells become
//  transparent with a glowing stamp-ink border — the grid is what lights up.
//

import SwiftUI

struct PassportCollageView: View {

    let photoCount: Int

    @Environment(\.passportRenderMode) private var mode
    private var isUV: Bool { mode.isUV }

    /// Glow colours cycled across the empty cells under UV.
    private let emptyGlow: [Color] = [.stampCobalt, .stampViolet, .stampTeal]

    var body: some View {
        PassportPage {
            ZStack {
                let cells = CollageTemplate.cells(photoCount: photoCount)
                let styled = Self.withEmptyIndices(cells)
                ForEach(styled, id: \.offset) { item in
                    cellView(item.cell, emptyIndex: item.emptyIndex)
                        .frame(width: item.cell.rect.width, height: item.cell.rect.height)
                        .referenceOrigin(x: item.cell.rect.minX, y: item.cell.rect.minY)
                }
            }
        }
    }

    @ViewBuilder
    private func cellView(_ cell: CollageCell, emptyIndex: Int) -> some View {
        if cell.isPhoto {
            PassportPhotoSlot(isUV: isUV)
        } else if isUV {
            // Empty cell after dark — transparent with a glowing stamp-ink border.
            let color = emptyGlow[emptyIndex % emptyGlow.count]
            Rectangle()
                .strokeBorder(color, lineWidth: 1.5)
                .shadow(color: color.opacity(0.6), radius: 4)
        } else {
            // Empty cell in daylight — outline only, paper showing through.
            Rectangle()
                .strokeBorder(Color.ink, lineWidth: 1.5)
        }
    }

    /// Tags each cell with its running index and, for empty cells, the index
    /// among empties (so their glow colours cycle).
    private static func withEmptyIndices(_ cells: [CollageCell])
        -> [(offset: Int, cell: CollageCell, emptyIndex: Int)] {
        var empty = 0
        return cells.enumerated().map { offset, cell in
            defer { if !cell.isPhoto { empty += 1 } }
            return (offset, cell, cell.isPhoto ? 0 : empty)
        }
    }
}

/// A stand-in for a photo until the photo model exists. In daylight: a soft
/// neutral field with a faint photo glyph. After dark: dark and non-reactive
/// (photographs don't fluoresce) with only a faint teal edge.
private struct PassportPhotoSlot: View {
    let isUV: Bool
    var body: some View {
        if isUV {
            Rectangle()
                .fill(Color.uvCell)
                .overlay(Rectangle().strokeBorder(Color.stampTeal.opacity(0.5), lineWidth: 1.5))
        } else {
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
}

#Preview {
    HStack(spacing: 12) {
        PassportCollageView(photoCount: 3)
            .frame(width: 232, height: 330)
            .environment(\.passportRenderMode, .daylight)
        PassportCollageView(photoCount: 1)
            .frame(width: 232, height: 330)
            .environment(\.passportRenderMode, .uv)
    }
    .padding()
    .background(Color.muted)
}
