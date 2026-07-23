//
//  PassportBackCoverView.swift
//  InTouch
//
//  The back cover (design 2e) — the same oxblood material as the front, far
//  quieter: no wordmark, no holder name, just the field.
//
//  Wired for now as the *inside*-back — the right page of the book's final
//  spread. A true outside back cover (its own full-bleed state after the last
//  spread) is a separate task; see the passport-outside-back-cover note.
//

import SwiftUI

struct PassportBackCoverView: View {
    var body: some View {
        PassportCoverField()
    }
}

#Preview {
    PassportBackCoverView()
        .frame(width: 232, height: 330)
        .padding()
        .background(Color.muted)
}
