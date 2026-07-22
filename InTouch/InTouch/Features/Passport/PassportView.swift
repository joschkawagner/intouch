//
//  PassportView.swift
//  InTouch
//
//  The passport tab, now one screen with three lenses on the same collection:
//  Stamps (the grid), Map (later), Calendar (your history as a list).
//
//  The masthead and lens picker are a fixed header; only the lens content scrolls
//  beneath them, so the picker never scrolls away. The world map and share export
//  arrive in Phase 5.
//

import SwiftUI

/// The three ways to read the passport.
enum PassportLens: String, CaseIterable {
    case stamps, map, calendar

    var title: String {
        switch self {
        case .stamps: "Stamps"
        case .map: "Map"
        case .calendar: "Calendar"
        }
    }
}

struct PassportView: View {

    @State private var lens: PassportLens = .stamps

    private let cities = MockData.cities
    private let entries = MockData.entries

    var body: some View {
        VStack(spacing: 0) {
            MastheadView(
                title: "Passport",
                detail: "\(cities.count) cities · \(entries.count) photos"
            )

            PassportLensPicker(selection: $lens)
                .padding(.bottom, 10)

            switch lens {
            case .stamps:
                EmptyStateView(
                    title: "The passport is being rebound",
                    message: "The stamp page is coming back as a real passport booklet you leaf through. We pulled the old stamps while we build it.",
                    ghostLabel: "Stamps",
                    footnote: "YOU HAD TO BE THERE"
                )
            case .map:
                PassportMapLens(cities: cities)
            case .calendar:
                PassportCalendarLens(entries: entries)
            }
        }
        .paperBackground()
    }
}

#Preview {
    PassportView()
}
