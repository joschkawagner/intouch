//
//  PrivacyView.swift
//  InTouch
//
//  Privacy settings. Two toggles, both REAL — `@AppStorage`, persisted across
//  launches — and neither CONSUMED anywhere yet. The "soon" beside each says
//  exactly that, and it is about the missing enforcement, not about the switch:
//  flip it and the value survives a relaunch; nothing downstream reads it.
//
//  WHY ONLY TWO, when a settings screen usually carries a dozen. Most privacy
//  toggles would misrepresent this product rather than configure it:
//
//  · Content visibility is THE invariant — decided by proof of presence, never
//    by preference. A "who can see my posts" switch would contradict the one
//    rule the whole app exists to enforce.
//  · There is no analytics to opt out of (CLAUDE.md forbids it outright), and a
//    switch disabling something that does not exist implies collection that is
//    not happening.
//  · Precise coordinates are never stored (PRD § 6). A switch implying they
//    might be would be a lie rendered in the UI.
//
//  What survives that filter is a genuine local preference (app lock) and the
//  one place PRD § 6's own text implies a choice — the coarse ~1 km pin the map
//  uses, as distinct from the city and country a stamp always keeps.
//
//  KEYS STAY LOCAL, deliberately. They will be read by the handshake and stamp
//  code when enforcement lands, and that is the moment to lift them to Core —
//  extract when the second consumer exists, not when it is forecast.
//

import SwiftUI

struct PrivacyView: View {

    private enum Key {
        static let requireFaceID = "privacy.requireFaceIDOnLaunch"
        static let approximateLocation = "privacy.approximateLocationOnStamps"
    }

    /// Defaults describe the world as it is today, not as we would like it.
    /// Face ID is not enforced, so the lock is off; stamps do carry a coarse
    /// pin already, so that one is on. A default that misdescribes current
    /// behaviour is a bug the first time someone consumes it.
    @AppStorage(Key.requireFaceID) private var requireFaceID = false
    @AppStorage(Key.approximateLocation) private var approximateLocation = true

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                Text(Typography.chrome("Privacy"))
                    .font(Typography.masthead)
                    .foregroundStyle(Color.ink)
                    .padding(.horizontal, 20)
                    .padding(.top, 8)
                    .padding(.bottom, 24)

                PrivacyToggle(
                    label: "Require Face ID to open InTouch",
                    note: "Face ID stays on this device — nothing about your face is stored or sent.",
                    isOn: $requireFaceID
                )

                Divider().background(Color.muted.opacity(0.4)).padding(.horizontal, 20)

                PrivacyToggle(
                    label: "Approximate location on new stamps",
                    note: "Only the ~1 km pin the map draws. City and country are kept either way.",
                    isOn: $approximateLocation
                )

                Text(Typography.chrome("Both switches save. Neither is enforced yet."))
                    .font(Typography.label)
                    .foregroundStyle(Color.muted)
                    .padding(.horizontal, 20)
                    .padding(.top, 28)
            }
            .padding(.bottom, 40)
        }
        .scrollIndicators(.hidden)
        .paperBackground()
        .navigationBarTitleDisplayMode(.inline)
    }
}

/// One privacy switch: label, a muted "soon", the control, and a note beneath.
///
/// The `soon` sits INSIDE the toggle's label rather than beside it, so VoiceOver
/// announces it too — a user who cannot see the marker still learns the switch
/// is not enforced. That is the opposite decision from About's legal rows, and
/// deliberately so: those are not actionable and must not pretend to be, while
/// this one genuinely is actionable and must not pretend otherwise.
private struct PrivacyToggle: View {

    let label: String
    let note: String
    @Binding var isOn: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Toggle(isOn: $isOn) {
                HStack(spacing: 10) {
                    Text(Typography.chrome(label))
                        .font(Typography.body)
                        .foregroundStyle(Color.text)
                    Spacer(minLength: 0)
                    Text(Typography.chrome("soon"))
                        .font(Typography.label)
                        .foregroundStyle(Color.muted)
                }
            }
            .tint(Color.ink)

            Text(note)
                .font(Typography.label)
                .foregroundStyle(Color.muted)
                .fixedSize(horizontal: false, vertical: true)
                .accessibilityHidden(true)   // spoken as part of the toggle's hint instead
        }
        .padding(.vertical, 15)
        .padding(.horizontal, 20)
        .accessibilityHint(note)
    }
}

#Preview {
    NavigationStack { PrivacyView() }
}
