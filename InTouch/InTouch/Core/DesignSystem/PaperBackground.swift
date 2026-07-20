//
//  PaperBackground.swift
//  InTouch
//
//  The page surface every non-ceremonial screen sits on.
//
//  Flat for now. DESIGN.md calls for film grain and paper texture — when we add
//  it, it goes in here and every screen picks it up for free. That's the whole
//  reason this is a view instead of just writing `.background(Color.paper)`
//  in fifteen places.
//

import SwiftUI

struct PaperBackground: View {
    var body: some View {
        Color.paper
            .ignoresSafeArea()
    }
}

extension View {
    /// Places this view on the app's paper surface.
    func paperBackground() -> some View {
        background(PaperBackground())
    }
}

#Preview {
    Text("Paper")
        .font(Typography.body)
        .foregroundStyle(Color.text)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .paperBackground()
}
