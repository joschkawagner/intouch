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
    /// Typography. The three Jost weights are bundled (Info.plist UIAppFonts); Courier
    /// and the collage hand ship with iOS, so they aren't in UIAppFonts, but a renamed
    /// or dropped system font would still fall back silently — so the audit checks them too.
    static let expected = [
        "Jost-Regular",
        "Jost-SemiBold",
        "Jost-Bold",
        "Courier",                 // Typography machine type (timestamps, marks) — system font, not bundled
        "Courier-Bold",
        "BradleyHandITCTT-Bold",   // Typography.collage — system font, not bundled
    ]

    /// Family-name stems we dump the full member list for, to read real PostScript names.
    private static let inspectFamilies = ["Jost"]

    static func log() {
        #if DEBUG
        print("── FontAudit ─────────────────────────────────────────────")
        for family in UIFont.familyNames.sorted()
        where inspectFamilies.contains(where: family.contains) {
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
