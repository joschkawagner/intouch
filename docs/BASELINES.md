# Baselines — the operative table

The six current pixel-gate values. This file is updated in the same commit whenever a
baseline moves **by design**; an unexplained mismatch against these values is a regression,
never a reason to edit this table. History and supersessions live in `DECISIONS.md`.

| Surface | Hash | Valid via |
|---|---|---|
| `zur-day` | `9f5fbe9ccd118a3e969d0f27757a3e3b` | Route A only |
| `zur-uv` | `63e9ab963927ba29672d55b10d1d0aba` | Route A only |
| `col-uv` | `15aa0e86e6118c7d6f98f0562e48064a` | Route A only |
| `col-day` | `b0b25a04b74dfef4650b71db81fbc7bd` | Route A only |
| `card-day` | `e3004da3ac4b85b078906783a5cabea6` | Any tested route (C settled · D carried-in · E chained), forced mode |
| `card-uv` | `485fe120f399903fd67a935c68e98f9e` | Any tested route (C settled · D carried-in · E chained), forced mode |

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
