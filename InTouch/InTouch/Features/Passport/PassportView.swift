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
//  ⚠️ THE TAB IS ALWAYS MY OWN BOOK. `PassportBookView` takes a holder now, and
//  this is the one place that answers "me". Another person's passport is reached
//  from their profile, never from this tab — you receive someone's record, you
//  do not switch identities inside your own document (DECISIONS.md 2026-07-26).
//

import SwiftUI

struct PassportView: View {
    var body: some View {
        PassportBookView(holder: MockData.currentUser,
                         contents: .currentUser)
        #if DEBUG
            .overlay(alignment: .topTrailing) { DebugUVChip().padding(8) }
        #endif
    }
}

#Preview {
    PassportView()
}
