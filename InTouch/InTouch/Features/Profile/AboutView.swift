//
//  AboutView.swift
//  InTouch
//
//  The About screen — the one Settings row that needs no backend at all, and
//  the reason it was built first: everything on it is either read from the
//  bundle or a fact about the project itself. Nothing is fetched, stored, or
//  user-specific, so none of it will be reshaped when Supabase lands.
//
//  VERSION AND BUILD ARE READ, NOT WRITTEN. `Bundle.main` is the only honest
//  source: a hardcoded version becomes a lie the moment someone bumps
//  MARKETING_VERSION and forgets this file. They render in the machine face
//  for the same reason the holder number does — a build number is a value a
//  machine stamped, not a word the design chose (see the typography decision
//  in docs/DECISIONS.md, 2026-07-26).
//
//  THE FONT LICENCE IS AN OBLIGATION, NOT A CREDIT. The SIL Open Font License
//  requires its text to travel with the font. It is read at runtime from the
//  very file that ships beside the font — Resources/Fonts/OFL-Jost.txt — so
//  the text on screen and the text in the bundle cannot drift apart. Copying
//  it into a Swift string literal would have created exactly that drift.
//

import SwiftUI

struct AboutView: View {

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                Text(Typography.chrome("About"))
                    .font(Typography.masthead)
                    .foregroundStyle(Color.ink)
                    .padding(.horizontal, 20)
                    .padding(.top, 8)
                    .padding(.bottom, 24)

                identity

                sectionHeader("Credits")
                credits

                sectionHeader("Legal")
                legal

                sectionHeader("Font licence")
                licence
            }
            .padding(.bottom, 40)
        }
        .scrollIndicators(.hidden)
        .paperBackground()
        .navigationBarTitleDisplayMode(.inline)
    }

    // MARK: - Sections

    private var identity: some View {
        VStack(alignment: .leading, spacing: 5) {
            Text(Typography.chrome(Self.appName))
                .font(Typography.body)
                .foregroundStyle(Color.text)

            Text("VERSION \(Self.version)  ·  BUILD \(Self.build)")
                .font(Typography.timestamp)
                .tracking(Typography.machineTracking)
                .foregroundStyle(Color.muted)
        }
        .padding(.horizontal, 20)
        .padding(.bottom, 30)
    }

    private var credits: some View {
        VStack(alignment: .leading, spacing: 14) {
            AboutCredit(role: "Typeface", value: "Jost, by indestructible type*")
            AboutCredit(role: "Maps", value: "Apple MapKit")
        }
        .padding(.horizontal, 20)
        .padding(.bottom, 30)
    }

    /// Placeholder policy and terms.
    ///
    /// **Deliberately NOT buttons, and deliberately without chevrons.** There is
    /// nothing behind them yet, and this project has already paid for the
    /// alternative: a control that announces itself as actionable and then does
    /// nothing is the exact defect found on the disabled page-turn chevron
    /// (docs/DECISIONS.md, 2026-07-26 — an inert announced control). A chevron
    /// would make the same promise visually. They are plain rows carrying a
    /// muted "soon", which is honest in both registers at once.
    private var legal: some View {
        VStack(spacing: 0) {
            AboutPending(label: "Privacy Policy")
            Divider().background(Color.muted.opacity(0.4)).padding(.horizontal, 20)
            AboutPending(label: "Terms of Service")
        }
        .padding(.bottom, 30)
    }

    private var licence: some View {
        Text(Self.fontLicence)
            .font(Typography.timestamp)
            .foregroundStyle(Color.text.opacity(0.75))
            .textSelection(.enabled)
            .padding(.horizontal, 20)
    }

    private func sectionHeader(_ title: String) -> some View {
        Text(Typography.chrome(title))
            .font(Typography.label)
            .foregroundStyle(Color.muted)
            .padding(.horizontal, 20)
            .padding(.bottom, 10)
    }

    // MARK: - Bundle reads

    private static var appName: String {
        Bundle.main.object(forInfoDictionaryKey: "CFBundleName") as? String ?? "InTouch"
    }

    private static var version: String {
        Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "—"
    }

    private static var build: String {
        Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as? String ?? "—"
    }

    /// The OFL text as it ships. Loaded once; the fallback states the failure
    /// rather than paraphrasing the licence, because a paraphrase of a licence
    /// is not the licence.
    private static let fontLicence: String = {
        guard let url = Bundle.main.url(forResource: "OFL-Jost", withExtension: "txt"),
              let text = try? String(contentsOf: url, encoding: .utf8)
        else {
            return "The font licence could not be read from the app bundle. "
                 + "It ships at Resources/Fonts/OFL-Jost.txt."
        }
        return text
    }()
}

/// One credit: a small set label above a machine-printed value.
private struct AboutCredit: View {

    let role: String
    let value: String

    var body: some View {
        VStack(alignment: .leading, spacing: 3) {
            Text(Typography.chrome(role))
                .font(Typography.label)
                .foregroundStyle(Color.muted)
            Text(value)
                .font(Typography.body)
                .foregroundStyle(Color.text)
        }
        .accessibilityElement(children: .combine)
    }
}

/// A row for something that will exist and does not yet. No chevron, no tap
/// target, no button trait — see `AboutView.legal`.
private struct AboutPending: View {

    let label: String

    var body: some View {
        HStack {
            Text(Typography.chrome(label))
                .font(Typography.body)
                .foregroundStyle(Color.text)
            Spacer()
            Text(Typography.chrome("soon"))
                .font(Typography.label)
                .foregroundStyle(Color.muted)
        }
        .padding(.vertical, 15)
        .padding(.horizontal, 20)
        .accessibilityElement(children: .combine)
    }
}

#Preview {
    NavigationStack { AboutView() }
}
