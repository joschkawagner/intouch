//
//  PassportCoverView.swift
//  InTouch
//
//  The closed passport cover (design 1c).
//
//  DESIGN.md § The passport cover: one InTouch cover tinted into the colour
//  *family* of the user's home-country passport (here the red family — Color.ink,
//  "Red Inferno"), that wears visibly with use. The cover carries its own
//  security printing (see PassportCoverField) — tone-on-tone by day,
//  fluorescing after dark.
//
//  The content is a bottom-... no: the design sets a lowercase "passport"
//  wordmark with the holder's name beneath it, flush-left in the upper third.
//  Authored at the 232×330 reference (see PassportPage) so the wordmark scales
//  with the floating cover card; PassportBookView sizes and rounds the card and
//  drops its shadow.
//
//  ⚠️ `user` HAS NO DEFAULT, AND MUST NOT BE GIVEN ONE. It used to default to
//  `MockData.currentUser`, so `PassportCoverView()` compiled anywhere and
//  silently struck the current holder's name — nothing at the call site showed
//  a person was involved at all. Once another person's passport can be opened,
//  that default is the difference between their book and a book with your name
//  on the front, with no compiler error to catch it. An explicit parameter
//  cannot be forgotten.
//

import SwiftUI

struct PassportCoverView: View {

    /// Whose book this is. NO DEFAULT, deliberately — see the file note above.
    let user: UserProfile

    @Environment(\.passportRenderMode) private var mode
    private var isUV: Bool { mode.isUV }

    var body: some View {
        ZStack(alignment: .topLeading) {
            PassportCoverField()

            VStack(alignment: .leading, spacing: 6) {
                Text(Typography.chrome("passport"))
                    .font(Typography.passportWordmark)
                    .foregroundStyle(Color.paper.opacity(isUV ? 0.55 : 1))

                Text(user.displayName.uppercased())      // holder name — struck uppercase
                    .font(Typography.passportLabel)
                    .tracking(Typography.stampTracking)
                    .foregroundStyle(Color.paper.opacity(isUV ? 0.4 : 0.7))
            }
            .padding(.leading, 15)
            .padding(.top, 111)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

#Preview {
    PassportCoverView(user: MockData.currentUser)
        .frame(width: 232, height: 330)
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .shadow(color: Color.text.opacity(0.32), radius: 12, y: 10)
        .padding(40)
        .background(Color.muted)
}
