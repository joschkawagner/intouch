//
//  PassportEntry.swift
//  InTouch
//
//  One photo/moment in a city — the unit the Calendar lens lists and the photo
//  count sums. A city can hold many entries; the map draws one pin per city, the
//  calendar draws one row per entry.
//
//  A thumbnail belongs here eventually; this phase the calendar is text + a
//  marker, so the field is deliberately left off until real JPGs land in MockData.
//

import Foundation

struct PassportEntry: Identifiable, Hashable {
    let id: String
    let city: PassportCity
    let date: Date
}
