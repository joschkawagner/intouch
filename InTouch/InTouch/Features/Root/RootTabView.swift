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
//  correct. Connect is wrapped in its own NavigationStack so a simulated scan can
//  push its result while the tab bar stays visible. The tab bar itself is styled in
//  Jost + palette by AppAppearance.
//

import SwiftUI

struct RootTabView: View {
    var body: some View {
        TabView {
            FriendsFeedView()
                .tabItem { Label(Typography.chrome("Friends"), systemImage: "person.2") }

            GroupsView()
                .tabItem { Label(Typography.chrome("Groups"), systemImage: "square.grid.2x2") }

            NavigationStack { ConnectView() }
                .tabItem { Label(Typography.chrome("Connect"), systemImage: "qrcode.viewfinder") }

            EventsView()
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
