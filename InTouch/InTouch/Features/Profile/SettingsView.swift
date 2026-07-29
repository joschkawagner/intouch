//
//  SettingsView.swift
//  InTouch
//
//  Placeholder settings. Every row is inert this phase — they exist so the shape
//  is right and so the App Store requirements have a home from day one: **Blocked
//  users** and reporting are mandatory for any app with user content (docs/PRD.md
//  § 6), so they ship even before they do anything.
//
//  Custom rows on paper rather than a system List, to keep the type in the display
//  face and the surface in the palette instead of inheriting UIKit's grouped-list chrome.
//

import SwiftUI

struct SettingsView: View {

    /// Where a row goes. `none` is the honest state for the rows whose content
    /// is backend-shaped and cannot be finished yet — see the P7 table in the
    /// plan for which those are and why.
    private enum Destination {
        case none, privacy, about
    }

    private struct Row: Identifiable {
        let id = UUID()
        let icon: String
        let label: String
        var destination: Destination = .none
    }

    private let rows: [Row] = [
        Row(icon: "person.crop.circle", label: "Account"),
        Row(icon: "lock", label: "Privacy", destination: .privacy),
        Row(icon: "hand.raised", label: "Blocked users"),
        Row(icon: "bell", label: "Notifications"),
        Row(icon: "info.circle", label: "About", destination: .about),
    ]

    @ViewBuilder
    private func destinationView(for destination: Destination) -> some View {
        switch destination {
        case .privacy: PrivacyView()
        case .about:   AboutView()
        case .none:    EmptyView()
        }
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                Text(Typography.chrome("Settings"))
                    .font(Typography.masthead)
                    .foregroundStyle(Color.ink)
                    .padding(.horizontal, 20)
                    .padding(.top, 8)
                    .padding(.bottom, 16)

                VStack(spacing: 0) {
                    ForEach(rows) { row in
                        if row.destination == .none {
                            SettingsRow(icon: row.icon, label: row.label)
                        } else {
                            NavigationLink { destinationView(for: row.destination) } label: {
                                SettingsRow(icon: row.icon, label: row.label)
                                    // The row is icon · label · Spacer · chevron, so without
                                    // an explicit shape the hit area is only the DRAWN glyphs
                                    // and the wide gap in the middle swallows taps. P0 deleted
                                    // this exact modifier as dead code, correctly — nothing was
                                    // tappable then. Wiring the first row brought it back.
                                    .contentShape(Rectangle())
                            }
                            .buttonStyle(.plain)   // keep the paper row, not a tinted system link
                        }
                        Divider().background(Color.muted.opacity(0.4)).padding(.leading, 56)
                    }
                }

                SettingsRow(icon: "rectangle.portrait.and.arrow.right", label: "Sign out", destructive: true)
                    .padding(.top, 24)
            }
            .padding(.bottom, 40)
        }
        .scrollIndicators(.hidden)
        .paperBackground()
        .navigationBarTitleDisplayMode(.inline)
    }
}

/// One inert settings row: icon, label, and a chevron unless it's a terminal action.
///
/// **Destructive rows render in `Color.alarm`, not `Color.ink`.** They used to
/// use `ink` — which on these screens is also the screen title and the on-state
/// toggle tint, so "Sign out" was the same colour as the heading above it and
/// warned of nothing.
///
/// ⚠️ **Colour is not the whole job, and the rest of it is not paint.** WCAG
/// 1.4.1 forbids colour as the sole carrier of meaning, so a destructive row
/// needs a non-visual signal too. Today it has one for free — no chevron, since
/// it is terminal rather than navigational — and it needs `role: .destructive`
/// the moment it becomes a real `Button`. That is deliberately NOT added now:
/// the row is inert, and giving an inert row a destructive announcement would
/// recreate the "inert announced control" defect this project already fixed on
/// the page-turn chevron. The announcement belongs with the wiring, not here.
private struct SettingsRow: View {

    let icon: String
    let label: String
    var destructive = false

    private var tint: Color { destructive ? Color.alarm : Color.text }

    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .resizable().scaledToFit()
                .frame(width: 20, height: 20)
                .foregroundStyle(tint)

            Text(Typography.chrome(label))
                .font(Typography.body)
                .foregroundStyle(tint)

            Spacer()

            if !destructive {
                Image(systemName: "chevron.right")
                    .resizable().scaledToFit()
                    .frame(width: 7)
                    .foregroundStyle(Color.muted)
            }
        }
        .padding(.vertical, 15)
        .padding(.horizontal, 20)
    }
}

#Preview {
    NavigationStack { SettingsView() }
}
