//
//  AvatarView.swift
//  InTouch
//
//  A circular avatar in `ink` with paper initials — small in the masthead, larger
//  on a profile. No photo yet; when avatars carry an image, the initials become the
//  fallback. Sized by `diameter` so one component serves both places and the type
//  scales with it (the point size is derived from the diameter, not hard-coded).
//

import SwiftUI

struct AvatarView: View {

    let initials: String
    var diameter: CGFloat = 34

    var body: some View {
        Circle()
            .fill(Color.ink)
            .overlay {
                if initials.isEmpty {
                    Image(systemName: "person.fill")
                        .resizable().scaledToFit()
                        .frame(width: diameter * 0.5)
                        .foregroundStyle(Color.paper)
                } else {
                    Text(initials)
                        .font(Typography.display(diameter * 0.42, .semiBold))
                        .foregroundStyle(Color.paper)
                }
            }
            .overlay(Circle().strokeBorder(Color.paper.opacity(0.5), lineWidth: 0.5))
            .frame(width: diameter, height: diameter)
    }
}

#Preview {
    HStack(spacing: 20) {
        AvatarView(initials: "JW", diameter: 34)
        AvatarView(initials: "ER", diameter: 72)
        AvatarView(initials: "", diameter: 72)
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .paperBackground()
}
