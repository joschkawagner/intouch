//
//  IDCardField.swift
//  InTouch
//
//  One label-over-value pair on the ID card — the card's field register in a
//  single place, so the six fields cannot drift apart from each other.
//
//  THE REGISTER IS INVERTED FROM THE PASSPORT PAGE. There, labels and values sit
//  at nearly the same size and the name is set in Jost. Here the LABEL is Jost
//  at 9.5pt and the VALUE is Courier at ~17pt — roughly 1:1.9, against the
//  page's 1:1.15. A page is printed and filled in; a card is personalised by a
//  machine, and that difference is what stops the card reading as a page turned
//  sideways.
//
//  The value is a @ViewBuilder rather than a String because exactly one field —
//  the name — is the card's fluorescing hero, and the rest are calm. Passing
//  the value in lets that stay a decision at the call site while the label
//  treatment stays identical for all six (the field-glow rule: ALL labels
//  render uvFieldLabel, no per-field exceptions).
//
//  ⚠️ NOT YET VERIFIED — nothing renders this. Everything about the ID card
//  except its terrain density is unverified until it is wired into ProfileView.
//

import SwiftUI

struct IDCardField<Value: View>: View {

    let label: String
    /// Column width, so a wrapping value (the bio) stays inside its column.
    var width: CGFloat
    @ViewBuilder var value: Value

    @Environment(\.passportRenderMode) private var mode
    private var isUV: Bool { mode.isUV }

    /// The label-to-value gap. 13pt at the card's reference — tighter than the
    /// passport page's 16pt, because the card's much larger value needs less
    /// air to separate from a much smaller label.
    static var labelGap: CGFloat { 13 }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(label.uppercased())
                .font(Typography.idCardLabel)
                .tracking(Typography.idCardLabelTracking)
                .foregroundStyle(isUV ? Color.uvFieldLabel : Color.text.opacity(0.5))
                .uvFieldLit(isUV)

            value
                .padding(.top, Self.labelGap - 9.5)   // gap measured baseline-ish
        }
        .frame(width: width, alignment: .leading)
    }
}

/// A calm machine-set value — Courier, and never glowing. Per the field-glow
/// rule the card gets AT MOST ONE fluorescing hero (the name); everything else
/// takes the uniform recede treatment in both modes.
struct IDCardValue: View {

    let text: String

    @Environment(\.passportRenderMode) private var mode
    private var isUV: Bool { mode.isUV }

    var body: some View {
        Text(text)
            .font(Typography.idCardValue)
            .foregroundStyle(isUV ? Color.uvFieldValue : Color.text)
            .uvFieldLit(isUV)
    }
}
