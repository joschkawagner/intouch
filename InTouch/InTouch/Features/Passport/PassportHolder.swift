//
//  PassportHolder.swift
//  InTouch
//
//  Mocked passport holder details that don't exist in the data model yet.
//
//  The design shows a holder number and a machine-readable (MRZ) band, but
//  UserProfile (Core/Models) has no passport-number field and this build must
//  not touch anything outside the passport feature. So these are derived/mocked
//  here, in-feature, until a real passport-number model arrives. Cosmetic only.
//

import Foundation

enum PassportHolder {

    /// Mocked holder number, shown as "1,924" (matches the design mock).
    static let number = 1924

    /// The holder number formatted for display, e.g. "1,924". Uses a fixed
    /// document grouping (comma) rather than the device locale, so the passport
    /// number reads the same everywhere — it is a document field, not local UI.
    static var formattedNumber: String {
        number.formatted(.number.locale(Locale(identifier: "en_US")))
    }

    /// The machine-readable band for a holder name, e.g.
    /// "JOSCHKA<WAGNER<<INT<1924<<<<…". Padded with filler so it overflows the
    /// band (the band clips it), the way a real MRZ line runs edge to edge.
    static func mrz(name: String) -> String {
        let coded = name.uppercased()
            .split(separator: " ")
            .joined(separator: "<")
        let core = "\(coded)<<INT<\(String(format: "%04d", number))"
        return core.padding(toLength: max(core.count, 44), withPad: "<", startingAt: 0)
    }
}
