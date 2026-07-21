//
//  PassportStampsView.swift
//  InTouch
//
//  The Stamps lens: the grid of stamps on printed guides, unchanged from Phase 0.
//  Tap a stamp to replay its landing — press-down plus a rigid haptic (silent in
//  the simulator, felt on a real device). The scattered, overlapping page comes
//  next phase.
//

import SwiftUI

struct PassportStampsView: View {

    private let stamps = MockData.stamps

    private let columns = [
        GridItem(.flexible(), spacing: 0),
        GridItem(.flexible(), spacing: 0),
    ]

    var body: some View {
        ScrollView {
            LazyVStack(spacing: 0) {
                LazyVGrid(columns: columns, spacing: 14) {
                    ForEach(stamps) { stamp in
                        StampView(
                            id: stamp.id,
                            city: stamp.city,
                            date: stamp.date,
                            kind: stamp.kind,
                            diameter: 150,
                            landsOnTap: true
                        )
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 6)
                    }
                }
                .padding(.horizontal, 12)
                .padding(.top, 10)
                .background(PrintedGuides())

                Text("EVERY STAMP COST AN EVENING")
                    .font(Typography.label)
                    .tracking(Typography.stampTracking)
                    .foregroundStyle(Color.muted)
                    .padding(.top, 28)
                    .padding(.bottom, 40)
            }
        }
        .scrollIndicators(.hidden)
    }
}

#Preview {
    PassportStampsView()
        .paperBackground()
}
