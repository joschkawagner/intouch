//
//  PassportRenderMode.swift
//  InTouch
//
//  How the passport is rendered right now: in daylight, or after dark (UV).
//  The whole booklet renders one way or the other — it's not a per-page toggle
//  and not a user control; it follows the time of day (see PassportTimeOfDay).
//  Every page reads it from the environment and switches its ground, fields and
//  inks off this single value.
//

import SwiftUI

enum PassportRenderMode {
    case daylight
    case uv

    var isUV: Bool { self == .uv }
}

// MARK: - Environment plumbing

private struct PassportRenderModeKey: EnvironmentKey {
    static let defaultValue: PassportRenderMode = .daylight
}

extension EnvironmentValues {
    /// The passport's current render mode, injected by PassportBookView and read
    /// by every page/component that renders differently after dark.
    var passportRenderMode: PassportRenderMode {
        get { self[PassportRenderModeKey.self] }
        set { self[PassportRenderModeKey.self] = newValue }
    }
}

// MARK: - Fluorescing glow

extension View {
    /// A soft fluorescing halo for the text and marks that glow after dark.
    /// Passing `.clear` disables it (daylight), so call sites can pass a colour
    /// conditionally and read declaratively.
    func fluoresce(_ color: Color) -> some View {
        shadow(color: color == .clear ? .clear : color.opacity(0.8),
               radius: color == .clear ? 0 : 4)
    }
}
