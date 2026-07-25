//
//  GroupsView.swift
//  InTouch
//
//  Phase 0: empty state only. Groups are built on the same feed primitive as
//  Friends and Events, so this fills in properly in Phase 6.
//

import SwiftUI

struct GroupsView: View {
    var body: some View {
        VStack(spacing: 0) {
            MastheadView(title: "Groups", detail: "none yet")

            EmptyStateView(
                title: "No groups yet",
                message: "A group is a handful of people you've already met. Start one after your next handshake — everyone in it has to be someone you've stood next to.",
                ghostLabel: "Groups",
                footnote: "NO INVITE LINKS"
            )
        }
        .paperBackground()
        .toolbar(.hidden, for: .navigationBar)
    }
}

#Preview {
    GroupsView()
}
