//
//  PassportView.swift
//  InTouch
//
//  The passport tab. Its home is the closed cover (portrait); rotating the phone
//  to landscape swings it open into a leaf-through book. See PassportBookView.
//
//  This replaced the old Map/Calendar lens picker: the map now lives inside the
//  book (spread 0). Calendar has no home in this design yet and is unreachable
//  from the tab for now — where it lands is a later task, not a bug.
//

import SwiftUI

struct PassportView: View {
    #if DEBUG
    // TEMPORARY (UV design-lab pass): LAB opens the page gallery. When the pass
    // lands, delete showLab + the LAB button + the fullScreenCover and restore
    // the bare DebugUVChip overlay. See PassportDesignLab.swift.
    @State private var showLab = false
    #endif

    var body: some View {
        PassportBookView()
        #if DEBUG
            .overlay(alignment: .topTrailing) {
                HStack(spacing: 8) {
                    DebugUVChip()
                    Button { showLab = true } label: {
                        Text("LAB")
                            .font(Typography.timestamp)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 5)
                            .background(Color.night)
                            .foregroundStyle(Color.paper)
                    }
                }
                .padding(8)
            }
            .fullScreenCover(isPresented: $showLab) { PassportDesignLab() }
        #endif
    }
}

#Preview {
    PassportView()
}
