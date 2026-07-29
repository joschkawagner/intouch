//
//  FeedPost.swift
//  InTouch
//
//  A post in the friends feed: a caption and one or more photos.
//
//  Numbered sample files that share a prefix (ski-1, ski-2) are ONE multi-photo
//  post — the app renders those as a swipeable carousel. That grouping lives in
//  `photos` below.
//

import Foundation

struct FeedPost: Identifiable, Hashable {
    let id: String

    /// Who posted it — a whole person, not a name.
    ///
    /// This was a bare `String` (audit finding A7), which meant the feed and the
    /// passport shared no identifier at all: a post by "Emil" and the profile of
    /// Emil Roth were two unrelated pieces of text. Nothing could route from a
    /// byline to a passport, which is what P11 needs.
    ///
    /// **Modelled as the JOINED row, not as embedded data.** In Postgres this is
    /// `posts.author_id → profiles.id`, and the feed query fetches the profile
    /// alongside the post (`select *, author:profiles(*)`). Holding a
    /// `UserProfile` here is that join result, not a claim that a post owns a
    /// copy of a person — a post never edits its author.
    let author: UserProfile

    let caption: String
    let city: String
    let date: Date

    /// Asset-catalogue image names, in display order. Always ≥ 1.
    ///
    /// One name renders as a plain full-bleed photo; two or more render as a paged
    /// carousel with page dots (see `PhotoCarouselView`). This is the shape the
    /// `post_media` table (id, storage_path, order_index) maps onto in Phase 3 —
    /// storing an array now means carousels are not retrofitted after the backend.
    let photos: [String]
}
