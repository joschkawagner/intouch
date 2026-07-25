//
//  RootTabView.swift
//  InTouch
//
//  The app shell: five plain tabs on paper, ink accents. Apple's standard TabView,
//  deliberately — it gives VoiceOver, tap-to-scroll-to-top, iPad adaptation and the
//  standard animations for free, none of which a hand-built bar would.
//
//  `connect` is an ordinary tab, not a special button. Selecting it shows the dark
//  Connect screen and stays selected: a scan leads somewhere, so staying put is
//  correct. The tab bar itself is styled in Jost + palette by AppAppearance.
//
//  The three list tabs each own a NavigationStack so they can push detail screens.
//  Each hides the system navigation bar and keeps its in-page MastheadView as the
//  header — the standing rule from DECISIONS.md 2026-07-20 (a UIKit nav bar can only
//  be restyled through appearance proxies, which leaks the design system).
//
//  Passport deliberately has NO stack: it pushes nothing, and its book does its own
//  safe-area maths off `geo.size` while clearing the system chrome when open. A
//  navigation bar would change that geometry for no gain.
//

import SwiftUI

struct RootTabView: View {
    var body: some View {
        TabView {
            NavigationStack { FriendsFeedView() }
                .tabItem { Label(Typography.chrome("Friends"), systemImage: "person.2") }

            NavigationStack { GroupsView() }
                .tabItem { Label(Typography.chrome("Groups"), systemImage: "square.grid.2x2") }

            NavigationStack { ConnectView() }
                .tabItem { Label(Typography.chrome("Connect"), systemImage: "qrcode.viewfinder") }

            NavigationStack { EventsView() }
                .tabItem { Label(Typography.chrome("Events"), systemImage: "mappin.and.ellipse") }

            PassportView()
                .tabItem { Label(Typography.chrome("Passport"), systemImage: "book.closed") }
        }
        .tint(Color.ink)
    }
}

#Preview {
    RootTabView()
}
