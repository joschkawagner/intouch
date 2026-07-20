//
//  AppAppearance.swift
//  InTouch
//
//  One-time UIKit appearance setup, called at app launch.
//
//  SwiftUI's TabView still renders a UIKit UITabBar underneath, and its
//  background and unselected colours can only be reached through UIKit's
//  appearance proxy. This file is the single place that bridge happens, and it
//  only ever reads tokens from Palette and Typography — no colours or sizes are
//  invented here.
//

import SwiftUI
import UIKit

enum AppAppearance {

    static func configure() {
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor(Color.paper)
        appearance.shadowColor = UIColor(Color.muted.opacity(0.6))

        style(appearance.stackedLayoutAppearance)
        style(appearance.inlineLayoutAppearance)
        style(appearance.compactInlineLayoutAppearance)

        UITabBar.appearance().standardAppearance = appearance
        UITabBar.appearance().scrollEdgeAppearance = appearance
    }

    private static func style(_ item: UITabBarItemAppearance) {
        item.normal.iconColor = UIColor(Color.muted)
        item.normal.titleTextAttributes = [
            .foregroundColor: UIColor(Color.muted),
            .font: Typography.tabLabelUIFont,
        ]
        item.selected.iconColor = UIColor(Color.ink)
        item.selected.titleTextAttributes = [
            .foregroundColor: UIColor(Color.ink),
            .font: Typography.tabLabelUIFont,
        ]
    }
}
