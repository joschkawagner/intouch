# VoiceOver session — the script

Everything here is **unverifiable by this project's own automation**. The accessibility snapshot
lists actionable targets, not accessibility elements (`RULES.md` R3), so it cannot report
hidden-ness, focus order, or announcements.

**But the tests do not all want the same instrument, and matching each one properly matters more
than running them all the same way** (revised 2026-07-26, before the session ran):

| Test | Instrument | Why this one |
|---|---|---|
| T1 · focus survives a page turn | **VoiceOver, by ear and eye** | only VoiceOver has focus |
| T2 · is the turn announced, and doubled | **VoiceOver, by ear** | only VoiceOver speaks |
| T3 · are both MRZ bands silent | **Accessibility Inspector** | confirming a negative by ear cannot distinguish *silent* from *missed* |
| T4a · Full Keyboard Access | **FKA, by keyboard** | directly and honestly testable |
| T4b · Switch Control | **not run** | awkward to drive in the simulator; an honest gap beats a bad test |
| T5 · can a VoiceOver user leave | **VoiceOver, by ear** | it is a question about what is announced |

**Pass conditions are stated in advance, before the session, deliberately.** T1 in particular
grades a decision that shipped the same day — a pass condition written afterwards is not a test,
it is a rationalisation. **T1's `DECISIONS.md` row is pre-committed in both directions**; see the
test itself.

## Setup

- Simulator → Settings → Accessibility → VoiceOver → **On**.
- **macOS VoiceOver OFF** (⌘F5). If it is on it swallows the Control+Option keystrokes before
  they reach the simulator, and the symptom looks like an unresponsive app rather than like a
  keyboard conflict.
- **Slow the speech rate first.** T2's failure mode is an announcement happening *twice*, and at
  the default rate a doubled announcement is hard to separate from one long one — which would
  leave T2 unresolved for a reason that has nothing to do with the product.
- Keyboard input must be routed to the device (I/O → Input; Apple has moved the exact label
  between Xcode versions).
- The book needs the simulator in **landscape** for T1, T2, T4a and T5. The ID card works in
  either orientation.

**⚠️ When the session ends, the post-session net at the bottom of this file is MANDATORY, and it
runs before any other work resumes.**

---

## T1 · Does focus survive a page turn? *(grades a shipped decision)*

**Why it matters most.** `38b3986` chose `.disabled(!enabled)` over
`.accessibilityHidden(!enabled)` for the boundary chevrons, on an argument that could not be
tested: that a disabled element stays in the tree so focus has somewhere to rest, where a
hidden one is removed and focus is discarded. **If T1 fails, that reasoning was wrong and the
mechanism should be reconsidered** — not patched around.

### Both directions, of equal standing — not a main test and a footnote

Both boundaries run the **same code path** (`edgeTap`, driven by `enabled:`), so **a mechanism
that survives one and not the other is itself a finding** — it would mean the cause sits outside
that path, and the obvious candidate is VoiceOver treating the first and last elements of a
container differently.

**Run B is the shorter route to the same event, and is worth running first.**

**Run A · forward.** From spread 1, focus **"Next page"**, then activate repeatedly — staying on
that element — until arriving at **spread 9 of 9**. Eight activations. The element under focus
disables on the last one.

**Run B · backward.** From spread 1, activate "Next page" once to reach spread 2. Move focus to
**"Previous page"**. Activate once → back to spread 1, and the element under focus disables.
**One activation, same event.**

*(Run B has to start from spread 2 because at spread 1 "Previous page" is already `.disabled`
and absent from the actionable-targets list entirely.)*

**Observe, in both runs.** Where VoiceOver focus lands immediately after the activation that
disables the focused chevron.

### What "focus survived" means — pinned before observation

Three outcomes, all named in advance so none can be argued into a verdict afterwards:

| Outcome | Verdict |
|---|---|
| Focus **stays on the disabled chevron**, which announces as unavailable ("dimmed") | **PASS** — the intended behaviour, and precisely the argument the mechanism was chosen on |
| Focus **moves to a sensible neighbour** — an adjacent element on the same spread | **PASS** — stated in advance deliberately, so it cannot be rationalised later; but see the discriminator |
| Focus **dumps to the top of the screen, or is lost entirely** | **FAIL** — falsifies the focus-stability argument |

**The line between the second and third outcomes is not taste — it is one more swipe.**
"Sensible neighbour" is not a judgment about whether the landing spot looks reasonable; it is
whether the user **keeps their place**. After the activation, swipe once more:

- The sequence **continues locally** from where you were → focus was genuinely retained. **PASS.**
- The sequence **restarts** — the next swipe walks in from the beginning of the screen → focus
  was discarded and VoiceOver simply reset to its default. **FAIL**, even if the element it
  landed on looked plausible.

This distinction is the whole reason to state it now: a discarded focus and a moved focus can
look identical in the instant after the activation. **The swipe afterwards is what separates
them**, and deciding that rule while looking at the result is how a fail becomes a pass.

### The DECISIONS row is pre-committed now, in both directions

Written 2026-07-26, before the test ran, so the result cannot be written to suit itself:

- **On PASS** → the row records that `.disabled(!enabled)` was the right mechanism *on the right
  reasoning*, and **the lowered-confidence / UNVERIFIED label comes off**. The focus-stability
  argument stops being a guess and becomes a measurement. `RULES.md` C1's third instance gets
  updated from "shipped on an untestable argument" to "shipped, then verified".
- **On FAIL** → the row states plainly that **the afternoon's reasoning was wrong**, and the
  mechanism is **reconsidered, not patched around**. No wrapper, no compensating announcement,
  no framing it as a refinement. A failure would mean "a control vanishing mid-sequence is the
  problem" was never the real diagnosis, and the fix has to restart from that — including
  revisiting whether `.accessibilityHidden` was right all along.
- **On a SPLIT** (one direction passes, the other fails) → the row records **which** direction
  failed and treats the split as its own finding rather than averaging the two into a verdict.
  Both boundaries run identical code, so a split locates the cause *outside* `edgeTap` — and a
  mechanism that only holds at one end of the sequence has not been validated, it has been
  half-falsified.

The row is written the same day the test runs, and it names which outcome occurred rather than
summarising the session.

---

## T2 · Is the page turn announced at all — and is it announced twice?

**Why.** `PageScrolled` was deliberately **not** implemented, on the reasoning that the
chevron's `.accessibilityValue` (`"Spread N of 9"`) already updates each turn and VoiceOver
re-announces a changed value on the focused element. If that reasoning is wrong, there is a
real gap and `PageScrolled` becomes construction-correct rather than a guess.

**Route.** As T1, but page between interior spreads (2 → 3 → 4), staying focused on
"Next page".

**Observe.** What VoiceOver says after each activation. *(This is the test the slowed speech
rate exists for.)*

**PASS** — the new spread number is announced exactly once per turn (e.g. "Spread 3 of 9").

**FAIL, gap** — nothing is announced; the user cannot tell the page changed. → implement
`PageScrolled`.

**FAIL, other** — the number is announced more than once. → a different defect; do **not** add
`PageScrolled`, which would make it worse.

---

## T3 · Are both MRZ bands silent? *(Accessibility Inspector, not the ear)*

**Why.** `282a2b9` marked both machine-readable bands decorative — the passport's identity page
and the ID card's machine strip — on the principle that a machine zone is not a reading zone.
Committed UNVERIFIED.

**⚠️ INSTRUMENT CHANGED 2026-07-26 — this test is NOT run by listening.** Confirming a negative
by ear cannot distinguish *silent* from *missed*: if the string is never announced, that is the
same experience as a tester whose attention lapsed for one swipe, and the test would pass for
the wrong reason. **Accessibility Inspector walks the real accessibility tree** — the exact gap
R3 named in the snapshot tool — so hidden-ness becomes something read rather than something
failed to be heard. This is the one test here whose result is *stronger* than a VoiceOver
observation, because it reads the tree directly instead of sampling what was spoken.

**Tool.** Xcode → Open Developer Tool → Accessibility Inspector, targeted at the simulator.

**Route (two surfaces).** (a) Passport tab, landscape, **spread 1 of 9** (identity page):
inspect every element on the spread. (b) Friends tab → avatar → the ID card: inspect every
element.

**Observe.** Whether any element carries the raw encoding —
`JOSCHKA<WAGNER<<INT<1924<<<<…` — as its label or its value.

**PASS** — the encoding is on no element on either surface, while the labelled rows (name,
handle, member since, cities, bio, holder number) are all present and correctly labelled.
Nothing readable was lost.

**FAIL** — the encoding is exposed anywhere, or a labelled field disappeared along with it.

---

## T4 · Can the chevrons be reached without touch?

**Why.** Never verified. The `.isButton` trait *should* make them reachable, and this was the
original motivation for annotating them at all (`d394378`) — untraversable UI is untestable UI.

### T4a · Full Keyboard Access — tested properly

**Setup.** Simulator → Settings → Accessibility → Keyboards → Full Keyboard Access → On.

**Route.** Passport tab, landscape, an interior spread so both chevrons are enabled. Tab
through the focusable items.

**Observe.** Whether both chevrons take focus and activate.

**PASS** — both reachable, both activate, and paging works.

**FAIL** — either is skipped or cannot be activated.

**Note the interaction with T1:** at the boundary spreads one chevron is `.disabled`, so it
should be *reachable but not activatable*. A disabled control that cannot be reached at all is
the same failure T1 tests for, seen from another angle.

### T4b · Switch Control — RECORDED AS UNTESTED, with the reason

**Not run, deliberately.** Switch Control is genuinely awkward to drive in the simulator, and a
half-driven test produces a result nobody should act on. **An honest gap beats a bad test:** a
"pass" obtained by fighting the harness would be indistinguishable from a real pass, and it
would retire the question permanently on no evidence.

**Recorded as:** *untested, pending a real device.* It blocks nothing else, and it deliberately
gets **no pass condition here** — inventing one for a test that will not run is exactly the
rationalisation this document exists to prevent.

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

## ⚠️ POST-SESSION, MANDATORY — two nets, then the work resumes

**Not optional, and it runs BEFORE anything else** — specifically before the back-cover item's
throwaway placeholder measurement.

**Why.** Enabling VoiceOver is exactly the hidden state R1 is about, and here it lands
immediately before a run of gated commits. If VoiceOver draws a focus ring or otherwise touches
rendering, a net run with it still enabled moves all four passport baselines for a reason that
has nothing to do with the change being gated — and it would present as the back-cover work
breaking Zürich. A false regression with a real-looking signature is the worst shape a defect
can take here.

**The step — two nets, in this order.**

1. **Net A, with VoiceOver STILL ON.** Operator step first (confirm landscape), then the full
   pinned order `zur-day → zur-uv → col-uv → col-day`. This net exists purely to measure
   whether VoiceOver-enabled moves pixels — a question nobody has answered.
2. **VoiceOver off. Full Keyboard Access off.** Confirm, don't assume.
3. **Net B, everything off.** Same pinned order. All four must match `BASELINES.md`.

**Reading the two nets — pre-committed:**

| Net A (VO on) | Net B (VO off) | Means |
|---|---|---|
| matches | matches | VoiceOver is render-inert **and** the session left no residue. Both facts are new; record the first. |
| differs | matches | **VoiceOver-enabled moves pixels.** A real finding and a standing hazard: no net may ever run with it enabled, and the operator step gains a second question. Record it. |
| — | differs | **STOP.** Do not re-baseline. Check process error first — VoiceOver or FKA still on, wrong spread, wrong mode, stale binary — because residue is likelier than a defect. |

---

## Recording the results

Add one `DECISIONS.md` row per test with the observed behaviour, then update this file's status.

- **T1's row is pre-committed above and must be written either way** — especially if it grades
  the shipped decision as wrong. That is the entire point of writing the pass condition first.
- **T4b gets a row too**, recording it as untested with the reason. A gap that is written down
  is a known gap; a gap that is silent becomes an assumed pass.
- **The post-session nets get a row** whenever Net A differs from Net B, because that is the
  VoiceOver-render-inertness measurement and it has never been made.
