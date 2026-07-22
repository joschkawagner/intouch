//
//  LabStampMarks.swift
//  InTouch
//
//  ⚠️ TEMPORARY — StampLab design lab. Safe to delete with the folder.
//
//  The small official-looking marks that give a stamp density: a landmark
//  silhouette, reference codes (0342 / B14 120 / AB123), a procedure word
//  (ARRIVAL, IMMIGRATION…), a plane, an arrow, a rank of stars. Real stamps are
//  busy; sparse ones look fake. Every mark is seeded from the stamp id, so a stamp
//  always carries the same marks.
//
//  Landmark silhouettes are SF Symbols standing in for the real thing — this is a
//  vocabulary lab, not final art; a shipping stamp would use a drawn landmark.
//

import SwiftUI

/// Seeded bundle of the little marks a stamp wears. Read the properties; place them
/// in `LabStampView`.
struct LabStampMarks {
    let seed: String

    private var rng: SeededGenerator { SeededGenerator(seed: seed + ".marks") }

    /// A travel-ish silhouette. SF Symbols, valid on iOS 18.
    var landmark: String {
        pick(from: ["building.columns.fill", "mountain.2.fill", "building.2.fill",
                    "tram.fill", "ferry.fill", "sailboat.fill", "globe.europe.africa.fill"],
             salt: "landmark")
    }

    /// A short alphanumeric reference, e.g. "0342".
    var code: String {
        var generator = SeededGenerator(seed: seed + ".code")
        let number = Int(generator.next(in: 100...9999))
        return String(number)
    }

    /// A second, lettered reference, e.g. "B14 · 120".
    var codeAlt: String {
        var generator = SeededGenerator(seed: seed + ".codeAlt")
        let letters = "ABCDEFGHJKLMNPRTVX"
        let letter = letters[letters.index(letters.startIndex,
                                           offsetBy: Int(generator.next(in: 0...Double(letters.count) - 0.001)))]
        let a = Int(generator.next(in: 10...99))
        let b = Int(generator.next(in: 100...999))
        return "\(letter)\(a) · \(b)"
    }

    /// A procedure word. POSIX-uppercase, machine voice.
    var word: String {
        pick(from: ["ARRIVAL", "DEPARTURE", "IMMIGRATION", "APPROVED", "ADMITTED", "TRANSIT"],
             salt: "word")
    }

    var showsPlane: Bool { flag(salt: "plane", chance: 0.55) }

    /// A direction arrow, or none. SF Symbol name.
    var arrow: String? {
        guard flag(salt: "arrow", chance: 0.45) else { return nil }
        return flag(salt: "arrowDir", chance: 0.5) ? "arrow.right" : "arrow.left"
    }

    var stars: Int {
        var generator = SeededGenerator(seed: seed + ".stars")
        return Int(generator.next(in: 0...3.999))
    }

    // MARK: - Seeded helpers

    private func pick(from options: [String], salt: String) -> String {
        var generator = SeededGenerator(seed: seed + "." + salt)
        return options[Int(generator.next(in: 0...Double(options.count) - 0.001))]
    }

    private func flag(salt: String, chance: Double) -> Bool {
        var generator = SeededGenerator(seed: seed + "." + salt)
        return generator.next(in: 0...1) < chance
    }
}

/// A short rank of stars, e.g. under a country name. Used by `LabStampView`.
struct StarRow: View {
    let count: Int
    var size: CGFloat = 6

    var body: some View {
        HStack(spacing: size * 0.5) {
            ForEach(0..<max(count, 0), id: \.self) { _ in
                Image(systemName: "star.fill")
                    .resizable().scaledToFit()
                    .frame(width: size, height: size)
            }
        }
    }
}
