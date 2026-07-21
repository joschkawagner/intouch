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
        case .event(let e): "\(e.venue) · \(e.city)"
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
                        .tracking(1)
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
            }
            .padding(.bottom, 40)
        }
        .scrollIndicators(.hidden)
        .paperBackground()
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview("Person") {
    NavigationStack { ScanResultView(result: .person(MockData.scannedPerson)) }
}

#Preview("Event") {
    NavigationStack { ScanResultView(result: .event(MockData.scannedEvent)) }
}
