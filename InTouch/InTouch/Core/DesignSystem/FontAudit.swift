//
//  FontAudit.swift
//  InTouch
//
//  A launch-time sanity check for bundled fonts, DEBUG only.
//
//  A bundled font that isn't registered — wrong filename in UIAppFonts, a
//  PostScript name that doesn't match the name table — fails *silently*: iOS
//  hands back the system face and the app looks almost right. This prints what
//  actually registered so we can confirm the real PostScript names instead of
//  assuming them. See docs/DECISIONS.md and the Typography display constant.
//

import UIKit

enum FontAudit {

    /// PostScript names we expect to be able to instantiate. Kept in sync with
    /// Typography's display face and the Info.plist UIAppFonts array.
    static let expected = [
        "JosefinSans-Regular",
        "JosefinSans-SemiBold",
        "JosefinSans-Bold",
    ]

    static func log() {
        #if DEBUG
        print("── FontAudit ─────────────────────────────────────────────")
        for family in UIFont.familyNames.sorted() where family.contains("Josefin") {
            print("family:", family)
            for name in UIFont.fontNames(forFamilyName: family).sorted() {
                print("   •", name)
            }
        }
        for name in expected {
            let ok = UIFont(name: name, size: 12) != nil
            print(ok ? "✓ loaded:" : "✗ MISSING (falls back to system):", name)
        }
        print("──────────────────────────────────────────────────────────")
        #endif
    }
}
