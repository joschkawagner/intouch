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
        // Kept out of VoiceOver's traversal path. A dev affordance has no
        // business in the sequence a VoiceOver user swipes through — and this
        // one is worse than noise, because it CHANGES APP STATE: landing on it
        // by accident and activating it contaminates a measurement silently
        // instead of failing loudly. That voided a T1 run outright — the
        // eighth activation hit the chip and toggled the lighting mode.
        //
        // AUTOMATION IS UNAFFECTED, and that is measured, not hoped: per
        // RULES.md R3 the MCP snapshot lists actionable TARGETS, and
        // `.accessibilityHidden` does not change actionability — so the chip
        // stays tappable by the harness that drives the pixel gates while
        // disappearing from assistive-technology traversal.
        .accessibilityHidden(true)
    }
}
#endif
