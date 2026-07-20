//
//  RootTabView.swift
//  InTouch
//
//  The app shell: four tabs on paper, ink accents.
//

import SwiftUI

struct RootTabView: View {
    var body: some View {
        TabView {
            FriendsFeedView()
                .tabItem { Label("Friends", systemImage: "person.2") }

            GroupsView()
                .tabItem { Label("Groups", systemImage: "square.grid.2x2") }

            EventsView()
                .tabItem { Label("Events", systemImage: "mappin.and.ellipse") }

            PassportView()
                .tabItem { Label("Passport", systemImage: "book.closed") }
        }
        .tint(Color.ink)
    }
}

#Preview {
    RootTabView()
}
