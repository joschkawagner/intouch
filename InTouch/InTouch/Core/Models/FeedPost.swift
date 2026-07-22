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
    let author: String
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
