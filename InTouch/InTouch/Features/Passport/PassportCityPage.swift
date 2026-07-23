//
//  PassportCityPage.swift
//  InTouch
//
//  The left page of a city spread — a plain city label. Reuses the calendar
//  lens's type roles: the place name in the display face, the date in Courier as
//  machine type, with the same ink-dot marker (see PassportCalendarLens.row).
//  The date is the most recent moment recorded in that city.
//

import SwiftUI

struct PassportCityPage: View {

    let city: PassportCity
    /// The most recent entry date for this city, if any.
    let date: Date?

    var body: some View {
        PassportPage(security: .standard) {
            VStack(alignment: .leading, spacing: 0) {
                HStack(spacing: 12) {
                    Circle()
                        .fill(Color.ink)
                        .frame(width: 8, height: 8)

                    Text(Typography.chrome(city.country))
                        .font(Typography.label)
                        .tracking(1.5)
                        .foregroundStyle(Color.muted)
                }

                Text(city.name)                             // a place name — never chrome()
                    .font(Typography.masthead)
                    .foregroundStyle(Color.ink)
                    .padding(.top, 12)

                if let date {
                    Text(Self.dateString(date))
                        .font(Typography.timestamp)         // Courier — the date as artifact
                        .tracking(1)
                        .foregroundStyle(Color.muted)
                        .padding(.top, 8)
                }

                Spacer(minLength: 0)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
            .padding(28)
        }
    }

    /// e.g. "14 MAR 2026" — same format as the calendar lens.
    private static let formatter: DateFormatter = {
        let f = DateFormatter()
        f.locale = Locale(identifier: "en_US_POSIX")
        f.dateFormat = "dd MMM yyyy"
        return f
    }()

    private static func dateString(_ date: Date) -> String {
        formatter.string(from: date).uppercased()
    }
}

#Preview {
    PassportCityPage(city: MockData.zurich, date: MockData.entries.first?.date)
}
