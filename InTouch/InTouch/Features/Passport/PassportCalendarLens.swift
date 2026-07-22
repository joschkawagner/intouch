//
//  PassportCalendarLens.swift
//  InTouch
//
//  The passport as a plain chronological history — one row per photo/moment,
//  newest first, no algorithm. Each row is a struck form line: an ink dot marker,
//  the city in the display face, and the date in Courier (dates are machine type,
//  never the interface face — see DESIGN.md § Typography).
//
//  This is deliberately not a stamp grid: the stamps were pulled last phase. A
//  thumbnail can join each row later; text + marker is the whole row for now.
//

import SwiftUI

struct PassportCalendarLens: View {

    let entries: [PassportEntry]

    /// Newest first. Source order in MockData is irrelevant; this is the sort.
    private var sorted: [PassportEntry] {
        entries.sorted { $0.date > $1.date }
    }

    var body: some View {
        ScrollView {
            LazyVStack(spacing: 0) {
                ForEach(sorted) { entry in
                    row(entry)
                    Divider()
                        .overlay(Color.muted.opacity(0.4))
                        .padding(.leading, 20)
                }
            }
            .padding(.top, 4)
        }
        .scrollIndicators(.hidden)
    }

    private func row(_ entry: PassportEntry) -> some View {
        HStack(spacing: 12) {
            Circle()
                .fill(Color.ink)
                .frame(width: 8, height: 8)

            Text(entry.city.name)                       // a place name — never chrome()
                .font(Typography.body)
                .foregroundStyle(Color.ink)

            Spacer(minLength: 12)

            Text(Self.dateString(entry.date))
                .font(Typography.timestamp)             // Courier — the date as artifact
                .tracking(1)
                .foregroundStyle(Color.muted)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 14)
        .contentShape(Rectangle())
    }

    /// e.g. "14 MAR 2026". Fixed en_US_POSIX so the month abbreviation never
    /// localises out from under the mechanical look.
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
    PassportCalendarLens(entries: MockData.entries)
        .paperBackground()
}
