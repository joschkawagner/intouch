//
//  PassportCalendarView.swift
//  InTouch
//
//  The Calendar lens: your history as a chronological list, newest first — every
//  connection made, event tapped into and group started. Each row is led by a small
//  StampView so the page still reads as stamps, not a table.
//

import SwiftUI

struct PassportCalendarView: View {

    /// Newest first.
    private var entries: [TimelineEntry] {
        MockData.timeline.sorted { $0.date > $1.date }
    }

    var body: some View {
        ScrollView {
            LazyVStack(spacing: 0) {
                ForEach(entries) { entry in
                    CalendarRow(entry: entry)
                    Divider()
                        .background(Color.muted.opacity(0.35))
                        .padding(.leading, 78)
                }
            }
            .padding(.top, 4)
            .padding(.bottom, 40)
        }
        .scrollIndicators(.hidden)
    }
}

private struct CalendarRow: View {

    let entry: TimelineEntry

    var body: some View {
        HStack(spacing: 16) {
            StampView(
                id: entry.id,
                city: entry.city,
                date: entry.date,
                kind: entry.kind.stampKind,
                diameter: 48
            )

            VStack(alignment: .leading, spacing: 3) {
                Text(entry.title)
                    .font(Typography.body)
                    .foregroundStyle(Color.text)
                Text("\(entry.kind.mark) · \(entry.city.uppercased())")
                    .font(Typography.timestamp)
                    .tracking(1)
                    .foregroundStyle(Color.muted)
            }

            Spacer()

            Text(Self.dateFormatter.string(from: entry.date).uppercased())
                .font(Typography.timestamp)
                .foregroundStyle(Color.muted)
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 20)
    }

    private static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "d MMM"
        return formatter
    }()
}

#Preview {
    PassportCalendarView()
        .paperBackground()
}
