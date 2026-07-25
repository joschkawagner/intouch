//
//  EventsView.swift
//  InTouch
//
//  Phase 0: empty state only. Create, tap-in, upload window and the recap card
//  arrive in Phase 4.
//

import SwiftUI

struct EventsView: View {
    var body: some View {
        VStack(spacing: 0) {
            MastheadView(title: "Events", detail: "nothing live")

            EmptyStateView(
                title: "Nothing on tonight",
                message: "An event shows up here the moment you tap in at the door.",
                ghostLabel: "Events"
            )
        }
        .paperBackground()
        .toolbar(.hidden, for: .navigationBar)
    }
}

#Preview {
    EventsView()
}
