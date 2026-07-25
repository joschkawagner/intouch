//
//  FriendsFeedView.swift
//  InTouch
//
//  Chronological feed of posts from confirmed connections. No algorithm, ever.
//
//  Phase 0: mock data, no view model. There's no async state to observe yet —
//  an @Observable wrapper around a static array would be ceremony. The model
//  arrives in Phase 3 with the real feed service.
//
//  The masthead sits OUTSIDE the ScrollView, as it does on Groups and Events —
//  inside the LazyVStack it scrolled away with the feed, taking the app's only
//  entry point to Profile with it, on a lazily-recycled row that also owned the
//  sheet.
//

import SwiftUI

struct FriendsFeedView: View {

    private let posts = MockData.posts

    var body: some View {
        VStack(spacing: 0) {
            // A count of posts, never of people — see DECISIONS.md 2026-07-25.
            MastheadView(title: "Friends", detail: "\(posts.count) posts")

            ScrollView {
                LazyVStack(spacing: 0) {
                    ForEach(posts) { post in
                        FeedCardView(post: post)
                    }
                }
            }
            .scrollIndicators(.hidden)
        }
        .paperBackground()
        .toolbar(.hidden, for: .navigationBar)
    }
}

#Preview {
    FriendsFeedView()
}
