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
            photo

            VStack(alignment: .leading, spacing: 6) {
                Text(post.caption)
                    .font(Typography.body)
                    .foregroundStyle(Color.text)

                Text("\(post.author.uppercased())  ·  \(post.city.uppercased())  ·  \(Self.timestampFormatter.string(from: post.date).uppercased())")
                    .font(Typography.timestamp)
                    .tracking(1)
                    .foregroundStyle(Color.muted)
            }
            .padding(.horizontal, 20)
        }
        .padding(.bottom, 28)
    }

    /// Placeholder for a real photo — see FeedPost.Tone. Deletes in Phase 3.
    private var photo: some View {
        LinearGradient(
            colors: post.tone.colours,
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .frame(height: 300)
        .overlay {
            Image(systemName: post.tone.symbol)
                .font(.system(size: 34))
                .foregroundStyle(Color.paper.opacity(0.35))
        }
        .clipped()
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
