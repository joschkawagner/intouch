#if DEBUG
//
//  DebugUV.swift
//  InTouch
//
//  DEBUG-ONLY dev tool — permanent, sanctioned scaffolding.
//
//  A manual override of the passport render mode, bypassing the real
//  time-of-day boundary (PassportTimeOfDay) so both lighting states can be
//  exercised in the simulator at any hour. The chip cycles CLOCK → DAY → UV
//  (CLOCK follows the real boundary). This whole file is inside `#if DEBUG`,
//  so it is compiled out of release builds entirely — the shipped passport
//  only ever follows the clock.
//

import SwiftUI

@Observable
final class DebugUV {
    static let shared = DebugUV()

    /// nil = follow the real clock; otherwise force this mode.
    var forced: PassportRenderMode?

    func cycle() {
        forced = switch forced {
        case nil: .daylight
        case .daylight: .uv
        case .uv: nil
        }
    }

    private var label: String {
        switch forced {
        case nil: "CLOCK"
        case .daylight: "DAY"
        case .uv: "UV"
        }
    }

    var chipTitle: String { "DBG: " + label }
}

/// A small floating debug chip; tap to cycle clock → daylight → UV.
struct DebugUVChip: View {
    @State private var debug = DebugUV.shared

    var body: some View {
        Button { debug.cycle() } label: {
            Text(debug.chipTitle)
                .font(Typography.timestamp)
                .padding(.horizontal, 8)
                .padding(.vertical, 5)
                .background(Color.night)
                .foregroundStyle(Color.paper)
        }
    }
}
#endif
