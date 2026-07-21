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

    private let stamps = MockData.stamps

    private var cityCount: Int { Set(stamps.map(\.city)).count }

    var body: some View {
        VStack(spacing: 0) {
            MastheadView(
                title: "Passport",
                detail: "\(stamps.count) stamps · \(cityCount) cities"
            )

            PassportLensPicker(selection: $lens)
                .padding(.bottom, 10)

            switch lens {
            case .stamps:
                PassportStampsView()
            case .map:
                EmptyStateView(
                    title: "The map comes later",
                    message: "Every city you've stamped will surface here as a pin on a printed atlas. MapKit lands in a later phase.",
                    ghostLabel: "Map",
                    footnote: "PINS ARE STAMPS"
                )
            case .calendar:
                PassportCalendarView()
            }
        }
        .paperBackground()
    }
}

#Preview {
    PassportView()
}
