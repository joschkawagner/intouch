//
//  PassportRestingSurface.swift
//  InTouch
//
//  The surface the passport floats on. The design rests both the closed cover
//  and the open spread on the muted field with a margin (not filling the
//  screen), lit with soft corner vignettes so the book reads as an object set
//  down on a surface rather than a screen background.
//

import SwiftUI

struct PassportRestingSurface: View {

    @Environment(\.passportRenderMode) private var mode

    var body: some View {
        ZStack {
            if mode.isUV {
                // After dark the surface is the UV ground — the whole screen
                // drops away so the fluorescing book is all that's lit.
                Color.uvGround
                CornerVignettes(color: .black.opacity(0.35), reach: 0.4)
            } else {
                Color.muted
                CornerVignettes(color: Color.text.opacity(0.10), reach: 0.35)
            }
        }
    }
}

#Preview {
    PassportRestingSurface()
}
