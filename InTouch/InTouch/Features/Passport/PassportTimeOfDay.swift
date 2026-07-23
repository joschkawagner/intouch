//
//  PassportTimeOfDay.swift
//  InTouch
//
//  Decides whether the passport renders in daylight or UV, from the time of day.
//  UV is simply what the booklet looks like after dark — there is no gesture or
//  toggle to force it (see docs/DESIGN.md § the passport booklet).
//
//  PLACEHOLDER BOUNDARY: this uses a fixed local-hour cutoff — daylight from
//  07:00 to 18:59, UV from 19:00 to 06:59. A real sunrise/sunset calculation
//  needs the device's latitude/longitude (CoreLocation), which pulls in a
//  location-permission prompt and brushes the city-level-only privacy rule, so
//  it's deferred to its own increment. `renderMode` is the single seam to swap
//  the fixed cutoff for a solar calculation later.
//

import SwiftUI
import Combine

@Observable
final class PassportTimeOfDay {

    /// Daylight starts at 07:00.
    static let dayStartHour = 7
    /// UV (after dark) starts at 19:00.
    static let nightStartHour = 19

    /// The current hour drives `renderMode`; refreshed on a timer and when the
    /// app returns to the foreground, so the book flips at the boundary without
    /// a relaunch.
    private var hour = Calendar.current.component(.hour, from: Date())

    private var timerCancellable: (any Cancellable)?

    var renderMode: PassportRenderMode {
        (hour < Self.dayStartHour || hour >= Self.nightStartHour) ? .uv : .daylight
    }

    /// Begin tracking the hour. Cheap: a coarse timer, since the boundary only
    /// matters to the hour.
    func start() {
        refresh()
        timerCancellable = Timer.publish(every: 60, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in self?.refresh() }
    }

    func stop() {
        timerCancellable?.cancel()
        timerCancellable = nil
    }

    private func refresh() {
        hour = Calendar.current.component(.hour, from: Date())
    }
}
