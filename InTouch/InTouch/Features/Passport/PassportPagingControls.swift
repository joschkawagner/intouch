//
//  PassportPagingControls.swift
//  InTouch
//
//  Turning the page: one tap zone on each outer edge of the open spread.
//  Leafing is deliberately plain — an offset slide, no page-curl — and the taps
//  are edge zones rather than a drag gesture because the book is counter-rotated
//  (see DECISIONS.md 2026-07-23).
//
//  Extracted from `PassportBookView` verbatim. Nothing here is holder-aware, so
//  it moves out ahead of the parameterisation work rather than during it.
//
//  `mode` is a PARAMETER, not `@Environment(\.passportRenderMode)`, even though
//  this only ever renders inside that environment today. An implicitly-resolved
//  value is how `PassportCoverView` ended up silently bound to the current user
//  — right until someone renders it somewhere the default is wrong, with no
//  compiler error. An explicit parameter cannot be forgotten at a call site.
//

import SwiftUI

struct PassportPagingControls: View {

    let mode: PassportRenderMode
    @Binding var spreadIndex: Int
    let spreadCount: Int

    var body: some View {
        HStack(spacing: 0) {
            edgeTap(systemImage: "chevron.left",
                    label: "Previous page",
                    enabled: spreadIndex > 0) {
                if spreadIndex > 0 { spreadIndex -= 1 }
            }
            Spacer()
            edgeTap(systemImage: "chevron.right",
                    label: "Next page",
                    enabled: spreadIndex < spreadCount - 1) {
                if spreadIndex < spreadCount - 1 { spreadIndex += 1 }
            }
        }
    }

    private func edgeTap(systemImage: String,
                         label: String,
                         enabled: Bool,
                         action: @escaping () -> Void) -> some View {
        // Dark-red ink is invisible on the night ground — after dark the
        // chevrons render in lit paper, a step above the legibility floor
        // because the right chevron sits over the map page's grey tiles
        // (the lightest UV surface in the book).
        //
        // Without the accessibility block below these are bare Images
        // carrying a tap gesture: VoiceOver announces "chevron.left", Switch
        // Control and Full Keyboard Access can't reach them at all, and (how
        // this surfaced) no UI automation can page the book, because every
        // tap tool resolves an element from the accessibility tree and there
        // was nothing there to resolve. Untraversable UI is untestable UI.
        //
        // NO `.accessibilityElement()` here, deliberately. An SF Symbol Image
        // is already an accessibility element, so labelling it in place is
        // enough — whereas `.accessibilityElement()` MINTS a new one, which
        // sends SwiftUI down a different compositing path and shifts
        // sub-pixel antialiasing along this edge. Invisible to the eye,
        // caught by a checksum against the pre-change build. Annotate the
        // element that exists; don't create one.
        Image(systemName: systemImage)
            .font(Typography.body)
            .foregroundStyle(
                (mode.isUV ? Color.paper.opacity(0.55) : Color.ink.opacity(0.35))
                    .opacity(enabled ? 1 : 0)
            )
            .frame(width: 72)
            .frame(maxHeight: .infinity)
            .contentShape(Rectangle())
            .onTapGesture { if enabled { action() } }
            .allowsHitTesting(enabled)
            .accessibilityLabel(label)
            .accessibilityValue("Spread \(spreadIndex + 1) of \(spreadCount)")
            .accessibilityAddTraits(.isButton)
            .accessibilityAction { if enabled { action() } }
            // At the first and last spread the corresponding chevron is drawn at
            // opacity 0 and `allowsHitTesting(false)` — but neither of those
            // touches the accessibility tree, so VoiceOver reached a button
            // announced "Previous page, Spread 1 of 9" whose action did
            // nothing. An inert announced control.
            //
            // DISABLED, NOT HIDDEN, and the difference is FOCUS. This shipped
            // as `.accessibilityHidden(!enabled)` in cd29b81 and that was
            // WRONG: the element a VoiceOver user is focused on when they reach
            // the last spread is the very chevron that then disappears, so
            // focus is discarded and dumped to the top of the screen. Hiding
            // breaks the sequence at exactly the moment it triggers. `.disabled`
            // keeps the element present, keeps focus stable, and announces
            // "dimmed" — which TELLS the user they have reached the end of the
            // book, better information than silence.
            //
            // The reasoning that produced the wrong choice is worth keeping,
            // because the category error will recur: "the accessibility tree
            // should match what is presented" is sound, but it was applied to
            // VISUAL presentation — for a user who is not looking. What is
            // presented to a VoiceOver user is a SEQUENCE OF REACHABLE THINGS,
            // and a control vanishing mid-sequence is a discontinuity, not
            // fidelity.
            //
            // ✅ VERIFIED ON HARDWARE — iPhone 13 mini, iOS 26.5.2, VoiceOver,
            // 2026-07-28. BOTH boundaries pass, both on the strongest outcome:
            // focus stays on the chevron as it becomes disabled. The forward
            // boundary announced its own retention rather than leaving it to be
            // inferred — "Nächste Seite. Spread neun von neun. Grau dargestellt,
            // Taste" ("dimmed, button"), with focus still on the element. A
            // backward swipe then reached colophon-only content, so a sequence
            // demonstrably exists behind the landing point.
            //
            // The earlier note here claimed no instrument existed for this. One
            // did — a real device — and the claim was really that none was to
            // hand. See docs/VOICEOVER-SESSION.md § T1 and RULES.md § C1b.
            .disabled(!enabled)
    }
}
