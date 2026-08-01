//
//  FeedCardView.swift
//  InTouch
//
//  DESIGN.md component notes: photo full-bleed edge to edge, caption below in
//  `text` on `paper`, small mechanical timestamp. No avatars cluttering the
//  frame — a single line of attribution.
//
//  Stays in Features/Friends/ because only the friends feed uses it. If Groups
//  or Events end up rendering the same card, it moves to Core/Components/.
//

import SwiftUI

struct FeedCardView: View {

    let post: FeedPost

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            PhotoCarouselView(photos: post.photos)

            VStack(alignment: .leading, spacing: 6) {
                Text(post.caption)
                    .font(Typography.body)
                    .foregroundStyle(Color.text)

                // `shortName`, not `displayName`: the byline has always shown a
                // first name. That used to happen because the fixture *was* a
                // first name; now that a post carries a whole person, the rule is
                // stated rather than implied. Renders identically to before.
                //
                // `city.name` for the same reason: the post now carries a whole
                // `PassportCity` rather than a place name, and the byline wants
                // the name off it. `PassportCity.id` IS its name, so this is the
                // identifier, not a label derived from one.
                Text("\(post.author.shortName.uppercased())  ·  \(post.city.name.uppercased())  ·  \(Self.timestampFormatter.string(from: post.date).uppercased())")
                    .font(Typography.timestamp)
                    .tracking(Typography.machineTracking)
                    .foregroundStyle(Color.muted)
            }
            .padding(.horizontal, 20)
        }
        .padding(.bottom, 28)
    }

    private static let timestampFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "d MMM · HH:mm"
        return formatter
    }()
}

#Preview {
    FeedCardView(post: MockData.posts[0])
        .paperBackground()
}
