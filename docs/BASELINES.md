# Baselines — the reference values

**⚠️ DEMOTED 2026-07-29 — a pixel net is a SPOT-CHECK, not a gate.** It blocks nothing. An
unexplained mismatch is **no longer automatically a regression**: it is one observation, to
be diagnosed on its own terms alongside every hidden precondition `RULES.md` R1 enumerates
— the wall-clock hour, the orientation, the route, the cached refs, what was actually in the
build. `col-uv` is the standing case in point and is still open.

**The values below are still the reference.** Demoting the net changes what a mismatch
*obliges*, not what the numbers *are*. This file is still updated in the same commit
whenever a baseline moves **by design**; history and supersessions live in `DECISIONS.md`.

**When to run one: before something that genuinely worries you** — a change to the book's
geometry, to a shared `Core/SecurityPrinting` primitive, to a page's layout. Not as ceremony
around every commit. A net run out of habit is not evidence of correctness in the first
place: the finding of 2026-07-28 is that the page-turn chevron has been overlapping colophon
content since at least `2a864e0` while `col-day` reproduced byte-exact around it. **A wrong
pixel rendered consistently passes every net forever.** Four passing frames certify that
nothing moved, never that anything is right.

**THIS FILE IS THE ONLY SOURCE OF HASH TRUTH.** Never read a value out of a `DECISIONS.md`
row, a commit message or a plan file — those record what was true when written, and at least
one of them has already gone stale without noticing. A second document carrying these
literals is wrong by construction, not merely out of date.

| Surface | Hash | Valid via |
|---|---|---|
| `zur-day` | `9f5fbe9ccd118a3e969d0f27757a3e3b` | Route A only |
| `zur-uv` | `e7c3538d857bf83f6fa28630c093bdc5` | Route A only |
| `col-uv` | `ccb5420bf36a82b99f8197a0fa6d91e8` | Route A only |
| `col-day` | `b0b25a04b74dfef4650b71db81fbc7bd` | Route A only |
| `card-day` | `e3004da3ac4b85b078906783a5cabea6` | Any tested route (C settled · D carried-in · E chained), forced mode |
| `card-uv` | `485fe120f399903fd67a935c68e98f9e` | Any tested route (C settled · D carried-in · E chained), forced mode |

> **⚠️ `col-uv` IS UNDER INVESTIGATION as of 2026-07-28.** A net that night held 5/6 — every
> other value above reproduced byte-exact — while `col-uv` alone did not. The value in the
> table is **unchanged and still the reference**; it has not been re-baselined and no fix has
> been attempted. Expect a mismatch on that one frame until this resolves, and do not treat it
> as a fresh regression. Details and the ruled-out causes are in `DECISIONS.md`, 2026-07-28.

Passport captures follow the pinned route A in the pinned order (`zur-day` → `zur-uv` →
`col-uv` → `col-day`), full-frame lossless PNG, wall-clock hour recorded.

**OPERATOR STEP — before any passport net, no exceptions:** route A requires the simulator
physically in **LANDSCAPE** (the book must be open for the chevrons to exist). The agent
cannot rotate the simulator and cannot see which way it is facing; only the operator can.
So every passport net begins with: **the agent stops, asks the operator to rotate the
simulator to landscape (Cmd+arrow), and waits for explicit confirmation before the first
capture.** A net run without that confirmed step is not a valid measurement. This was
implicit until 2026-07-26 — the sim had simply stayed in landscape since the baselines were
first cut.

The card baselines are **orientation-independent, measured**: both modes byte-identical with
the simulator in portrait and in landscape (2026-07-26).

Last full pass: 2026-07-26, commit `ae5f563`.
