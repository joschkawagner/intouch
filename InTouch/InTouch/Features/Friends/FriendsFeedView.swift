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

import SwiftUI

struct FriendsFeedView: View {

    private let posts = MockData.posts

    var body: some View {
        ScrollView {
            LazyVStack(spacing: 0) {
                MastheadView(title: "Friends", detail: "\(posts.count) posts · 12 connected")

                ForEach(posts) { post in
                    FeedCardView(post: post)
                }
            }
        }
        .scrollIndicators(.hidden)
        .paperBackground()
    }
}

#Preview {
    FriendsFeedView()
}
