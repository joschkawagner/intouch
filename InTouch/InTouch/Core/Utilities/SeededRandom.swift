//
//  SeededRandom.swift
//  InTouch
//
//  Deterministic randomness, seeded from a stable string id.
//
//  Why this exists instead of `id.hashValue`:
//  Swift seeds its standard hasher randomly on every process launch. `hashValue`
//  is stable while the app runs, but the same string hashes differently after a
//  relaunch. A stamp seeded that way would sit at a different angle every time
//  you reopen the app. DESIGN.md requires a stamp's imperfections to be fixed
//  forever, so the hash is hand-rolled here.
//

import Foundation

/// A small, fast, fully deterministic random number generator (SplitMix64).
///
/// Same seed in, same sequence out — on any device, on any launch, forever.
struct SeededGenerator: RandomNumberGenerator {

    private var state: UInt64

    init(seed: UInt64) {
        // Avoid a zero state, which would degenerate the sequence.
        self.state = seed == 0 ? 0x9E37_79B9_7F4A_7C15 : seed
    }

    /// Seeds from a string using FNV-1a, so a stamp id maps to one fixed sequence.
    init(seed: String) {
        var hash: UInt64 = 0xCBF2_9CE4_8422_2325 // FNV-1a 64-bit offset basis
        for byte in seed.utf8 {
            hash ^= UInt64(byte)
            hash &*= 0x0000_0100_0000_01B3 // FNV-1a 64-bit prime
        }
        self.init(seed: hash)
    }

    mutating func next() -> UInt64 {
        state &+= 0x9E37_79B9_7F4A_7C15
        var z = state
        z = (z ^ (z >> 30)) &* 0xBF58_476D_1CE4_E5B9
        z = (z ^ (z >> 27)) &* 0x94D0_49BB_1331_11EB
        return z ^ (z >> 31)
    }
}

extension SeededGenerator {
    /// A deterministic value in `range`. Convenience so call sites read cleanly.
    mutating func next(in range: ClosedRange<Double>) -> Double {
        .random(in: range, using: &self)
    }
}
