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

    /// Mocked holder number.
    static let number = 1924

    /// The holder number as the machine prints it: zero-padded, ungrouped —
    /// identical to the %04d core the MRZ strikes, because a real document's
    /// printed serial matches its machine zone. The earlier form ran the
    /// number through a quantity formatter ("1,924"); serials do not group,
    /// and that comment argued carefully about WHICH grouping to use while
    /// never asking WHETHER to group. See DECISIONS.md 2026-07-26.
    static var formattedNumber: String {
        String(format: "%04d", number)
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
