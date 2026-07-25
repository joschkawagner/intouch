//
//  EmptyStateView.swift
//  InTouch
//
//  DESIGN.md: "Empty states matter more than usual. A new user has an empty
//  everything. The empty passport should look like a blank passport — inviting,
//  not broken."
//
//  So an empty screen here isn't a shrug and a grey icon. It's an unstamped
//  page: the same ring the real stamps use, drawn faint, waiting to be filled.
//
//  Lives in Core/ rather than a feature folder because Groups and Events both
//  use it — that's CLAUDE.md's rule for when something graduates out of Features/.
//

import SwiftUI

struct EmptyStateView: View {

    let title: String
    let message: String

    /// The word set inside the ghost stamp.
    let ghostLabel: String

    /// Small letterspaced line at the bottom, in the product's voice. Optional:
    /// a screen only earns one if it has something factual to say about how the
    /// thing works. It is not a slot to be filled — most screens shouldn't
    /// explain themselves at all.
    var footnote: String? = nil

    var body: some View {
        VStack(spacing: 22) {
            ghostStamp

            VStack(spacing: 8) {
                Text(title)
                    .font(Typography.emptyTitle)
                    .foregroundStyle(Color.ink)

                Text(message)
                    .font(Typography.bodySmall)
                    .foregroundStyle(Color.text.opacity(0.75))
                    .multilineTextAlignment(.center)
                    .lineSpacing(3)
                    .frame(maxWidth: 260)
            }

            if let footnote {
                Text(footnote)
                    .font(Typography.label)
                    .tracking(Typography.stampTracking)
                    .foregroundStyle(Color.muted)
                    .padding(.top, 4)
            }
        }
        .padding(.horizontal, 32)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private var ghostStamp: some View {
        ZStack {
            StampRing(seed: ghostLabel, inset: 5)
                .stroke(
                    Color.muted,
                    style: StrokeStyle(lineWidth: 1.5, dash: [5, 5])
                )

            Text(ghostLabel.uppercased())
                .font(Typography.stampMark)
                .tracking(Typography.stampTracking)
                .foregroundStyle(Color.muted)
        }
        .frame(width: 118, height: 118)
        .rotationEffect(.degrees(-4))
        .opacity(0.7)
    }
}

#Preview {
    EmptyStateView(
        title: "No groups yet",
        message: "A group is a handful of people you've already met. Start one after your next handshake — everyone in it has to be someone you've stood next to.",
        ghostLabel: "Groups",
        footnote: "NO INVITE LINKS"
    )
    .paperBackground()
}
