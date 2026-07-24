//
//  PassportCityPage.swift
//  InTouch
//
//  The left page of a city spread (design 2b) — the city label, over the
//  standard security printing: the place name as a masthead, the country code
//  and most-recent date in Courier machine type, an ink dot, and the city's
//  coordinates. Laid out at the 232×330 reference with each line pinned to its
//  design coordinate.
//
//  After dark: the masthead is this page's one hero glow (field-glow rule,
//  see Palette.swift, UV inks); every other line renders calm.
//

import SwiftUI

struct PassportCityPage: View {

    let city: PassportCity
    /// The most recent entry date for this city, if any.
    let date: Date?

    @Environment(\.passportRenderMode) private var mode
    private var isUV: Bool { mode.isUV }

    var body: some View {
        PassportPage(security: .standard, seed: city.name) {
            ZStack {
                Text(city.name)                             // a place name — never chrome()
                    .font(Typography.masthead)
                    .foregroundStyle(isUV ? Color.stampViolet : Color.ink)
                    .fluoresce(isUV ? Color.stampViolet : .clear)
                    .referenceOrigin(x: 14, y: 118)

                Text(city.country.uppercased())             // document code — kept uppercase
                    .font(Typography.timestamp)
                    .tracking(Typography.stampTracking)
                    .foregroundStyle(isUV ? Color.uvFieldValue : Color.text.opacity(0.6))
                    .uvFieldLit(isUV)
                    .referenceOrigin(x: 14, y: 160)

                if let date {
                    Text(Self.dateString(date))
                        .font(Typography.timestamp)         // Courier — the date as artifact
                        .tracking(Typography.stampTracking)
                        .foregroundStyle(isUV ? Color.uvFieldValue : Color.text)
                        .uvFieldLit(isUV)
                        .referenceOrigin(x: 14, y: 182)
                }

                Circle()
                    .fill(isUV ? Color.uvFieldValue : Color.ink)
                    .frame(width: 8, height: 8)
                    .referenceOrigin(x: 14, y: 212)

                Text(Self.coordString(city))
                    .font(Typography.passportCoord)
                    .tracking(1)
                    .foregroundStyle(isUV ? Color.uvFieldValue : Color.text.opacity(0.45))
                    .uvFieldLit(isUV)
                    .referenceOrigin(x: 14, y: 246)
            }
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

    /// e.g. "47.3769°N · 8.5417°E".
    private static func coordString(_ city: PassportCity) -> String {
        let ns = city.latitude >= 0 ? "N" : "S"
        let ew = city.longitude >= 0 ? "E" : "W"
        return String(format: "%.4f°%@ · %.4f°%@", abs(city.latitude), ns, abs(city.longitude), ew)
    }
}

#Preview {
    PassportCityPage(city: MockData.zurich, date: MockData.entries.first?.date)
        .frame(width: 232, height: 330)
        .padding()
        .background(Color.muted)
}
