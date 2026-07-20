//
//  PassportView.swift
//  InTouch
//
//  The passport page: a grid of stamps on printed guides.
//
//  Phase 0 shows all three ink colours side by side so the component can be
//  judged. Tap a stamp to replay its landing — press-down plus a rigid haptic
//  (silent in the simulator, felt on a real device).
//
//  The world map and the share export arrive in Phase 5.
//

import SwiftUI

struct PassportView: View {

    private let stamps = MockData.stamps

    private let columns = [
        GridItem(.flexible(), spacing: 0),
        GridItem(.flexible(), spacing: 0),
    ]

    private var cityCount: Int {
        Set(stamps.map(\.city)).count
    }

    var body: some View {
        ScrollView {
            LazyVStack(spacing: 0) {
                MastheadView(
                    title: "Passport",
                    detail: "\(stamps.count) stamps · \(cityCount) cities"
                )

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
        .paperBackground()
    }
}

#Preview {
    PassportView()
}
