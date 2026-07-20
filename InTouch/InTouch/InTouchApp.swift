//
//  InTouchApp.swift
//  InTouch
//
//  Created by Joschka Wagner on 20.07.2026.
//

import SwiftUI

@main
struct InTouchApp: App {

    init() {
        AppAppearance.configure()
    }

    var body: some Scene {
        WindowGroup {
            RootTabView()
        }
    }
}
