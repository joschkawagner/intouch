# VoiceOver session — the script

Everything here is **unverifiable by automation**. The accessibility snapshot lists actionable
targets, not accessibility elements (`RULES.md` R3), so it cannot report hidden-ness, focus
order, or announcements. These five tests need VoiceOver running, driven by hand.

**Pass conditions are stated in advance, before the session, deliberately.** Test 1 in
particular grades a decision that has already shipped — a pass condition written afterwards is
not a test, it is a rationalisation.

**Setup:** Simulator → Settings → Accessibility → VoiceOver → On. The book requires the
simulator in **landscape** (Cmd+arrow) for tests 1–4; the ID card works in either orientation.

---

## T1 · Does focus survive a page turn? *(grades a shipped decision)*

**Why it matters most.** `38b3986` chose `.disabled(!enabled)` over
`.accessibilityHidden(!enabled)` for the boundary chevrons, on an argument that could not be
tested: that a disabled element stays in the tree so focus has somewhere to rest, where a
hidden one is removed and focus is discarded. **If T1 fails, that reasoning was wrong and the
mechanism should be reconsidered** — not patched around.

**Route.** Passport tab, landscape (book opens). Swipe to focus **"Next page"**. Activate it
repeatedly to page forward, staying on that element, until arriving at **spread 9 of 9** — the
moment the forward chevron becomes disabled.

**Observe.** Where VoiceOver focus lands immediately after the activation that reaches spread 9.

**PASS** — focus remains on the "Next page" element, which now announces as unavailable
(typically "dimmed"). The user knows they are at the end and has not lost their place.

**FAIL** — focus jumps elsewhere (top of screen, another element, or is lost entirely). That
falsifies the focus-stability argument the mechanism was chosen on.

**Also run backwards:** page to **spread 1 of 9** with focus on "Previous page". Same pass
condition. Both boundaries use the same code path, so a split result would itself be a finding.

---

## T2 · Is the page turn announced at all — and is it announced twice?

**Why.** `PageScrolled` was deliberately **not** implemented, on the reasoning that the
chevron's `.accessibilityValue` (`"Spread N of 9"`) already updates each turn and VoiceOver
re-announces a changed value on the focused element. If that reasoning is wrong, there is a
real gap and `PageScrolled` becomes construction-correct rather than a guess.

**Route.** As T1, but page between interior spreads (2 → 3 → 4), staying focused on
"Next page".

**Observe.** What VoiceOver says after each activation.

**PASS** — the new spread number is announced exactly once per turn (e.g. "Spread 3 of 9").

**FAIL, gap** — nothing is announced; the user cannot tell the page changed. → implement
`PageScrolled`.

**FAIL, other** — the number is announced more than once. → a different defect; do **not** add
`PageScrolled`, which would make it worse.

---

## T3 · Are both MRZ bands silent?

**Why.** `282a2b9` marked both machine-readable bands decorative — the passport's identity page
and the ID card's machine strip — on the principle that a machine zone is not a reading zone.
Committed UNVERIFIED.

**Route (two surfaces).** (a) Passport tab, landscape, **spread 1 of 9** (identity page): swipe
through every element on the spread. (b) Friends tab → avatar → the ID card: swipe through
every element.

**Observe.** Whether any element announces the raw encoding —
`JOSCHKA<WAGNER<<INT<1924<<<<…` — or spells it character by character.

**PASS** — the string is never announced on either surface, while the labelled rows (name,
handle, member since, cities, bio, holder number) all still are. Nothing readable was lost.

**FAIL** — the encoding is announced anywhere, or a labelled field went silent with it.

---

## T4 · Can Switch Control and Full Keyboard Access reach the chevrons?

**Why.** Never verified. The `.isButton` trait *should* make them reachable, and this was the
original motivation for annotating them at all (`d394378`) — untraversable UI is untestable UI.

**Route.** Enable Switch Control, then separately Full Keyboard Access. Passport tab,
landscape, an interior spread so both chevrons are enabled. Step through the focusable items.

**Observe.** Whether both chevrons are reachable and activatable by each technology.

**PASS** — both reachable, both activate, and paging works.

**FAIL** — either is skipped or cannot be activated.

**Note the interaction with T1:** at the boundary spreads one chevron is `.disabled`, so it
should be *reachable but not activatable* under both technologies. A disabled control that
cannot be reached at all is the same failure T1 tests for, seen from another angle.

---

## T5 · Can a VoiceOver user leave the Passport tab while the book is open?

**Why.** With the book open the tab bar is hidden by design, so the only way out is rotating
the device back to portrait — and **nothing announces this.** Diagnosed in `3dca617`; the
remaining question is discoverability, and it is a design question that T5 informs rather than
settles.

**Route.** Passport tab, landscape, book open. Attempt to navigate to any other tab using
VoiceOver only, without rotating.

**Observe.** Whether any announced element offers a way out, and whether anything indicates
that rotating closes the book.

**PASS** — a route out is discoverable by announcement alone.

**FAIL** — the user is stuck in the open book with no announced exit. → the rotate-to-close
discoverability item (P6 ·2) becomes a defect rather than a nicety, and its design options
(an `.accessibilityHint` on the spread, an announcement on open, or an explicit close
affordance) get decided on this evidence.

---

## Recording the results

Add one `DECISIONS.md` row per test with the observed behaviour, then update this file's
status. **T1's result must be recorded even — especially — if it grades the shipped decision as
wrong**; that is the point of writing the pass condition first.
