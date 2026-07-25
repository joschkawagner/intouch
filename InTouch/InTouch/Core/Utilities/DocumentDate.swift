//
//  DocumentDate.swift
//  InTouch
//
//  Date strings in the document register — uppercase, machine-set, locale-fixed.
//
//  These formats were duplicated as four private static DateFormatters across
//  the passport pages (identity, colophon, city, calendar), each constructing
//  the same thing. `en_US_POSIX` is deliberate and non-negotiable: a passport
//  is a printed document, so its dates must read identically regardless of the
//  reader's locale settings, and POSIX is the only locale guaranteed not to
//  shift under the user.
//
//  DateFormatter construction is expensive, so both stay `static let` — the
//  same caching the originals had.
//

import Foundation

enum DocumentDate {

    /// e.g. "SEP 2025" — the "member since" / "issued" register.
    static func monthYear(_ date: Date) -> String {
        monthYearFormatter.string(from: date).uppercased()
    }

    /// e.g. "19 JUL 2026" — a specific recorded day.
    static func dayMonthYear(_ date: Date) -> String {
        dayMonthYearFormatter.string(from: date).uppercased()
    }

    private static let monthYearFormatter = formatter("MMM yyyy")
    private static let dayMonthYearFormatter = formatter("dd MMM yyyy")

    private static func formatter(_ format: String) -> DateFormatter {
        let f = DateFormatter()
        f.locale = Locale(identifier: "en_US_POSIX")
        f.dateFormat = format
        return f
    }
}
