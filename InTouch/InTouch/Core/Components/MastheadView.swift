//
//  MastheadView.swift
//  InTouch
//
//  The header at the top of each tab.
//
//  Drawn in-page rather than using a system navigation bar. A UIKit nav bar
//  can only be restyled through UINavigationBarAppearance proxies, which means
//  font and colour decisions leaking out of the design system into app setup
//  code. Since Phase 0 has nowhere to navigate to, an in-page masthead keeps
//  every type and colour choice inside DesignSystem where it belongs. Real
//  NavigationStacks come back in Phase 1, for screens that actually push.
//

import SwiftUI

struct MastheadView: View {

    let title: String

    /// Small letterspaced detail line — a count, a status. Passport form field.
    let detail: String

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(detail.uppercased())
                .font(Typography.label)
                .tracking(Typography.stampTracking)
                .foregroundStyle(Color.muted)

            Text(title)
                .font(Typography.masthead)
                .foregroundStyle(Color.ink)

            Rectangle()
                .fill(Color.muted.opacity(0.5))
                .frame(height: 1)
                .padding(.top, 8)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 20)
        .padding(.top, 8)
        .padding(.bottom, 14)
    }
}

#Preview {
    VStack {
        MastheadView(title: "Passport", detail: "6 stamps · 5 cities")
        Spacer()
    }
    .paperBackground()
}
