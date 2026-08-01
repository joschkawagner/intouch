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

    /// Where it was taken — a place, not a place name.
    ///
    /// The other half of audit finding A7, and the same defect as `author` was:
    /// a bare `String` meant the feed's "Zürich" and `MockData.zurich` were two
    /// unrelated pieces of text about one city, so nothing could route from a
    /// byline to a map pin. `PassportCity` already existed and already fit — its
    /// `id` is its name and it is `Hashable`, which is what `FeedPost: Hashable`
    /// needs — so this adopts that type rather than inventing a parallel one.
    ///
    /// **Holding a city is NOT a claim that it is one of yours.** `MockData.cities`
    /// is the current user's own passport; a post's city is wherever the *author*
    /// was standing. A friend posting from Verbier does not put Verbier in your
    /// passport. See the fixture note in `MockData` — the two lists are separate
    /// on purpose.
    let city: PassportCity

    let date: Date

    /// Asset-catalogue image names, in display order. Always ≥ 1.
    ///
    /// One name renders as a plain full-bleed photo; two or more render as a paged
    /// carousel with page dots (see `PhotoCarouselView`). This is the shape the
    /// `post_media` table (id, storage_path, order_index) maps onto in Phase 3 —
    /// storing an array now means carousels are not retrofitted after the backend.
    let photos: [String]
}
