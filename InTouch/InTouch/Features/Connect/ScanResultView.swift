//
//  ScanResultView.swift
//  InTouch
//
//  Where a scan lands. A scan leads *somewhere* — a person you can connect with,
//  or an event you can tap into — so this is the payoff screen behind the Connect
//  tab's simulate buttons. The collage is the hero again, framed on paper; the
//  action beneath it is the one thing you came to do.
//
//  Actions are non-functional this phase (the real handshake — rotating QR,
//  reciprocal FaceID, proximity — is Phase 2). This only proves the screen exists
//  and reads right.
//

import SwiftUI

/// What a scan resolved to. Hashable so it can drive a `navigationDestination`.
enum ScanResult: Hashable {
    case person(UserProfile)
    case event(EventInfo)

    var collage: Collage {
        switch self {
        case .person(let p): p.collage
        case .event(let e): e.collage
        }
    }

    var title: String {
        switch self {
        case .person(let p): p.displayName
        case .event(let e): e.name
        }
    }

    var subtitle: String {
        switch self {
        case .person(let p): p.handle
        // `city.name`: an event now carries a whole `PassportCity`, and the
        // subtitle wants the name off it. `PassportCity.id` IS its name, so this
        // is the identifier, not a label derived from one. `venue` stays a bare
        // string — it is a room, not a place with coordinates.
        case .event(let e): "\(e.venue) · \(e.city.name)"
        }
    }

    /// A short line naming what this scan was.
    var kicker: String {
        switch self {
        case .person: "You scanned"
        case .event: "At the door"
        }
    }

    var actionLabel: String {
        switch self {
        case .person: "Connect"
        case .event: "Tap in"
        }
    }
}

struct ScanResultView: View {

    let result: ScanResult

    #if DEBUG
    /// Whose passport is open, if any. DEBUG-only for the same reason the route
    /// below is — see the note beside it.
    @State private var passportHolder: UserProfile?
    #endif

    var body: some View {
        ScrollView {
            VStack(spacing: 18) {
                Text(Typography.chrome(result.kicker))
                    .font(Typography.label)
                    .tracking(Typography.stampTracking)
                    .foregroundStyle(Color.muted)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 20)
                    .padding(.top, 8)

                CollageView(collage: result.collage)
                    .padding(.horizontal, 16)
                    .shadow(color: Color.text.opacity(0.18), radius: 12, x: 0, y: 6)

                VStack(spacing: 4) {
                    Text(result.title)                   // a person or event name — never chrome()
                        .font(Typography.masthead)
                        .foregroundStyle(Color.ink)
                    Text(result.subtitle)
                        .font(Typography.timestamp)
                        .tracking(Typography.machineTracking)
                        .foregroundStyle(Color.muted)
                }

                Button(action: {}) {                 // wired in Phase 2
                    Text(Typography.chrome(result.actionLabel))
                        .font(Typography.emptyTitle)
                        .foregroundStyle(Color.paper)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 15)
                        .background(Capsule().fill(Color.ink))
                }
                .padding(.horizontal, 40)
                .padding(.top, 6)

                passportRoute
            }
            .padding(.bottom, 40)
        }
        .scrollIndicators(.hidden)
        .paperBackground()
        .navigationBarTitleDisplayMode(.inline)
        #if DEBUG
        // Their PROFILE, not their book directly: PRD § 4.5 says another
        // person's profile IS their passport, so the profile screen is the
        // destination and ProfileView decides which document to draw. That also
        // inherits a presentation this project has already measured — the
        // fullScreenCover shape, in-page chrome, .statusBarHidden — and it
        // inherits the DebugUV chip, so this screen can force a lighting mode
        // instead of silently obeying whatever the Passport tab last set.
        //
        // derived(for:) rather than one of the six statics: a route has to work
        // for whoever was scanned, and the statics exist for previews.
        .fullScreenCover(item: $passportHolder) { holder in
            ProfileView(profile: holder,
                        contents: .derived(for: holder),
                        isOwnProfile: false)
        }
        #endif
    }

    /// ⚠️ DEV-ONLY ROUTE, AND THE CTA ABOVE IS DELIBERATELY UNTOUCHED.
    ///
    /// "Connect" names the handshake. What the handshake screen actually does is
    /// P8's to decide, and neither source that specifies it contains a Connect
    /// button at all: PRD § 3's v1 flow goes scan → both phones prompt FaceID,
    /// with no confirm tap, and DECISIONS.md 2026-07-26 has the ceremony showing
    /// both people their own ID card and trading them on share. Renaming the CTA
    /// to name a passport would be guessing at that and would have to be undone.
    /// So the route gets its own affordance and the string stays as it is.
    ///
    /// The whole block is fenced, label included — ConnectView's rule for its
    /// simulate buttons: shipping the control without the line explaining why it
    /// exists reads worse than shipping neither. Nothing here reaches Release,
    /// and neither does this screen: ScanResultView is only ever pushed from
    /// ConnectView's own #if DEBUG simulate block.
    @ViewBuilder
    private var passportRoute: some View {
        #if DEBUG
        if case .person(let person) = result {
            VStack(spacing: 10) {
                Text("NO HANDSHAKE YET")
                    .font(Typography.stampMark)
                    .tracking(Typography.stampTracking)
                    .foregroundStyle(Color.muted)

                Button { passportHolder = person } label: {
                    Text(Typography.chrome("Open their passport"))
                        .font(Typography.label)
                        .foregroundStyle(Color.ink)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 13)
                        .overlay(Capsule().stroke(Color.ink.opacity(0.45), lineWidth: 1.5))
                }
            }
            .padding(.horizontal, 40)
            .padding(.top, 14)
        }
        #endif
    }
}

#Preview("Person") {
    NavigationStack { ScanResultView(result: .person(MockData.scannedPerson)) }
}

#Preview("Event") {
    NavigationStack { ScanResultView(result: .event(MockData.scannedEvent)) }
}
