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

**Instances (2026-07-26):**
- `Color.uvShadow` — correct on principle, ~1.5% per channel at the spine's opacities, so
  nobody will see it land. Committed with that stated.
- Both MRZ bands hidden from VoiceOver — right by construction (a machine-encoding band is
  not a reading zone), but the available accessibility snapshot walks the view hierarchy
  rather than the assistive-technology tree, so it cannot confirm hidden-ness at all.
  Committed labelled *UNVERIFIED — no instrument exists for this claim*.

**What still applies:** the pixel gate is a separate question from the effect. Both instances
above were gate-checked even though their effects were not observable.
