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

    private struct Row: Identifiable {
        let id = UUID()
        let icon: String
        let label: String
        /// Only About is wired this phase — it is the one row that needs no
        /// backend at all, so it is the only one that can be finished rather
        /// than mocked. The rest stay inert until their phase; see the P7
        /// table in the plan for which of them are backend-shaped.
        var opensAbout = false
    }

    private let rows: [Row] = [
        Row(icon: "person.crop.circle", label: "Account"),
        Row(icon: "lock", label: "Privacy"),
        Row(icon: "hand.raised", label: "Blocked users"),
        Row(icon: "bell", label: "Notifications"),
        Row(icon: "info.circle", label: "About", opensAbout: true),
    ]

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
                        if row.opensAbout {
                            NavigationLink { AboutView() } label: {
                                SettingsRow(icon: row.icon, label: row.label)
                                    // The row is icon · label · Spacer · chevron, so without
                                    // an explicit shape the hit area is only the DRAWN glyphs
                                    // and the wide gap in the middle swallows taps. P0 deleted
                                    // this exact modifier as dead code, correctly — nothing was
                                    // tappable then. Wiring the first row brings it back.
                                    .contentShape(Rectangle())
                            }
                            .buttonStyle(.plain)   // keep the paper row, not a tinted system link
                        } else {
                            SettingsRow(icon: row.icon, label: row.label)
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
private struct SettingsRow: View {

    let icon: String
    let label: String
    var destructive = false

    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .resizable().scaledToFit()
                .frame(width: 20, height: 20)
                .foregroundStyle(destructive ? Color.ink : Color.text)

            Text(Typography.chrome(label))
                .font(Typography.body)
                .foregroundStyle(destructive ? Color.ink : Color.text)

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
