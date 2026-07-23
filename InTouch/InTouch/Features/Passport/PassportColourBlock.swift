//
//  PassportColourBlock.swift
//  InTouch
//
//  The right page of a city spread — a single solid Bauhaus block, standing in
//  for the real collage that arrives in a later pass. Each city gets one stable
//  colour: a deterministic fold over the name's bytes picks the block, so a city
//  always looks the same (NOT String.hashValue, which is randomised per launch).
//

import SwiftUI

struct PassportColourBlock: View {

    let city: PassportCity

    var body: some View {
        Self.colour(for: city.name)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    /// Stable, render-independent mapping from a city name to one Bauhaus block.
    static func colour(for name: String) -> Color {
        let blocks = Color.bauhausBlocks
        var hash: UInt64 = 5381                     // djb2, deterministic
        for byte in name.utf8 {
            hash = (hash &* 33) &+ UInt64(byte)
        }
        return blocks[Int(hash % UInt64(blocks.count))]
    }
}

#Preview {
    PassportColourBlock(city: MockData.zurich)
}
