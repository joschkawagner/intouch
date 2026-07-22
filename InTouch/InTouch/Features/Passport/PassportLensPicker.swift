//
//  PassportLensPicker.swift
//  InTouch
//
//  The Stamps · Map · Calendar switch. A custom control rather than a system
//  segmented Picker, so the type stays in the display face and the ink stays in the palette
//  instead of inheriting UISegmentedControl's chrome — and so the selected lens is
//  marked the way a passport marks a page: a struck underline, not a filled pill.
//

import SwiftUI

struct PassportLensPicker: View {

    @Binding var selection: PassportLens

    var body: some View {
        HStack(spacing: 0) {
            ForEach(PassportLens.allCases, id: \.self) { lens in
                let selected = lens == selection
                Button {
                    withAnimation(.easeOut(duration: 0.15)) { selection = lens }
                } label: {
                    VStack(spacing: 6) {
                        Text(Typography.chrome(lens.title))
                            .font(Typography.label)
                            .foregroundStyle(selected ? Color.ink : Color.muted)
                        Rectangle()
                            .fill(selected ? Color.ink : Color.clear)
                            .frame(height: 2)
                    }
                    .frame(maxWidth: .infinity)
                    .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, 20)
    }
}

#Preview {
    struct Harness: View {
        @State var lens: PassportLens = .stamps
        var body: some View {
            VStack {
                PassportLensPicker(selection: $lens)
                Spacer()
            }
            .paperBackground()
        }
    }
    return Harness()
}
