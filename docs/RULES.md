# Rules — checks that replace judgment calls

Each entry here started as a judgment someone had to make repeatedly, and became a check
anyone can apply without re-deriving it. Add one when a decision has been made the same way
twice and the reasoning is worth more than the instance. Keep them short enough to read
before acting; the reasoning and evidence live in `DECISIONS.md`.

---

## R1 · Before pinning any procedure, ask what state it depends on that the framebuffer doesn't show

A capture shows pixels. It does not show the conditions that produced them. Any procedure
pinned without naming its hidden preconditions will eventually be run under different ones,
and the difference will look like a regression in the product.

**Enumerate at least:** wall-clock time · device orientation · cached tool handles
(accessibility refs) · forced debug state · install/launch identity · safe-area insets ·
Dynamic Type · appearance.

**Why it exists.** Three instances landed in one day, each found by accident and none by
looking, because nothing in the procedure asked. The wall-clock hour changed an intermediate
frame; a cached elementRef dispatched a tap to whatever had moved under those pixels and
silently changed lighting mode; and the simulator sat in landscape for a full day unseen —
which was simultaneously what made route A work at all and what hid the passport's tab bar,
producing a false accessibility finding that had to be withdrawn.

**Apply it forward.** New surfaces get this question *before* their procedures are pinned,
not after a fourth instance.

---

## R2 · A shadow cannot add emission — any UV colour compositing above the ground is out on principle

Under blacklight there is no white light to scatter, so a shadow is **absent fluorescence**,
not absorbed light. It must read as less of the violet already present.

**The check:** composite the candidate at its intended opacity over `uvGround` and compare
per channel. If it lands **above the ground in any channel**, it is disqualified — it will
read as a faint glow, not a shadow. This is physics, not taste, so it settles the question
without a look comparison.

**Why it exists.** Three candidates for `Color.uvShadow` were rendered and compared on
screen. `0x090418` failed exactly here — at 0.45 over the ground its blue composited to
~21.8 against the ground's 20. The two survivors then differed by under half a percent per
channel, i.e. indistinguishable, so the remaining choice was margin rather than appearance.

---

## R3 · The accessibility snapshot lists ACTIONABLE TARGETS, not accessibility elements

It is a **navigation instrument, not an accessibility instrument.** It returns two lists — a
`targets` list of things you can dispatch a tap to, and a `text` list of rendered strings. That
single model explains every observation of it so far, and is what stops a third misreading.

**It can answer:** does an actionable element exist · can I resolve a ref and tap it · what
static text is rendered.

**It cannot answer:** is this hidden from assistive tech · focus order · what VoiceOver
announces · does modality apply.

**The two observations it took to get the model right:**
- `.accessibilityHidden(true)` — element **stays listed**. Hiding does not affect
  actionability, so the target survives. (First read as "the tool walks the view hierarchy",
  which was close but wrong.)
- `.disabled(true)` — element **drops out**. It is no longer actionable, so the target is gone.
  This is the tool working correctly, and it says nothing about VoiceOver focus.

**Consequence:** the disappearance or persistence of an entry in `targets` is evidence about
**tappability only**. Never read it as evidence about assistive-technology behaviour. Any claim
about hidden-ness, focus or announcement needs real VoiceOver, driven by hand — see C1.

---

# Recognised categories

Shapes worth naming so they are not re-litigated each time they appear.

## C1 · Correct and invisible

A change that is **right by construction but produces no observable difference** — either
because it is imperceptible, or because no instrument exists to confirm its effect.

**Ship it, with the limit stated in the commit.** Do not hold it pending verification that
cannot arrive, and do not describe it as verified. An uncommitted correct change carries its
own risk: it is lost across sessions, or re-decided by someone who does not know it was
already settled.

The discipline is **not** "ship only what's verified". It is **"never call something verified
when it isn't."**

### ⚠️ The boundary — C1 is not a licence to ship anything unverifiable

**"Right by construction" is the whole load-bearing condition.** It means the change is correct
by an argument that does not depend on observing it. A change that is *probably* right, or
right *if* an assumption holds, does not qualify — that is a **guess**, and shipping a guess
you cannot check is how an unverifiable defect enters and stays.

The test: *if I could observe the effect, is there an outcome that would surprise me?* If yes,
it is a guess. Hold it for real verification, or record the analysis and implement nothing.

**Worked example (2026-07-26).** `AccessibilityNotification.PageScrolled` on page turn was
considered and **deliberately not implemented**. The chevron's `.accessibilityValue` is already
`"Spread N of 9"` and updates every turn, and VoiceOver re-announces a changed value on the
focused element — so the announcement probably already happens and adding the notification
would likely **double** it. That fixes a gap whose existence could not be established, with a
change that might make things worse. Not construction-correct; not shipped. The analysis was
recorded instead.

**Instances (2026-07-26):**
- `Color.uvShadow` — correct on principle, ~1.5% per channel at the spine's opacities, so
  nobody will see it land. Committed with that stated.
- Both MRZ bands hidden from VoiceOver — right by construction (a machine-encoding band is
  not a reading zone), but no instrument can confirm hidden-ness (see R3).
  Committed labelled *UNVERIFIED — no instrument exists for this claim*.
- The disabled page-turn chevron marked `.disabled(!enabled)` — a real defect (an inert
  announced control) fixed on an untestable argument about focus stability, by a reasoner who
  had misread R3's instrument earlier the same day. Committed with the lowered confidence
  stated, on **asymmetric failure modes**: if this choice is wrong a user hears a redundant
  "dimmed" at the last spread; if the alternative was wrong they lose their place mid-book.
  **When two guesses are both unverifiable, ship the one that fails boringly.**

**What still applies:** the pixel gate is a separate question from the effect. Both instances
above were gate-checked even though their effects were not observable.
