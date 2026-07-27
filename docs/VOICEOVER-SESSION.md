# Accessibility verification — two sessions, one contract

**Rescoped 2026-07-26 evening, before any test ran.** The original script assumed VoiceOver
could be enabled in the simulator. It cannot — measured, not reported: Settings →
Bedienungshilfen on the booted iOS 26.2 runtime lists exactly six panes (Hover Text,
Display & Text Size, Motion, Spoken Content, Face ID & Attention, Control Nearby Devices),
scrolled to the top. **VoiceOver, Zoom, Switch Control and Keyboards are absent** — so Full
Keyboard Access is gone too. The components exist on disk and are UI-gated (`RULES.md` R4);
the session was scoped against an instrument nobody checked existed (`RULES.md` R1,
instance 5).

**The ordering correction, recorded as instructed.** This session was sequenced before the
back-cover work because **T1 grades a mechanism that shipped the same day**, and stacking
work on an unverified choice gets expensive to unwind. **That reason still stands.** It is
*outweighed* tonight — the decisive half needs hardware — **not dissolved.** Do not cite this
rescope as the ordering constraint going away. `.disabled(!enabled)` remains **UNVERIFIED**
and its lowered-confidence label stays on until Part II runs.

**Routes are now coordinate-free** — "the last spread", "the first spread", "an interior
spread" — because the back-cover work renumbers spreads. The pass conditions were always
about *the boundary event*, never about the number nine; phrasing the routes the same way
means renumbering can never invalidate this script again. (The `accessibilityValue` format is
"Spread N of M" with M tracking `spreadCount`; observations cite it with whatever M is
current.)

**Instrument per test** (revised; the principle is unchanged — match the instrument to the
question, and an honest gap beats a bad test):

| Question | Instrument | Session |
|---|---|---|
| P1 · is the disabled chevron still in the AX tree? | Accessibility Inspector | **I — now** |
| P2 · does `accessibilityValue` update per turn? | walker snapshots — **ANSWERED, see below** | I — done |
| P3 · do the chevrons carry the button trait? | Inspector (walker agrees, weakly) | I — now |
| T3 · are both MRZ bands silent? | Accessibility Inspector | **I — now** |
| T1 · does *focus* survive the boundary? | VoiceOver, by hand | **II — device** |
| T2 · is the turn *announced*, once? | VoiceOver, by ear | II — device |
| T4a · Full Keyboard Access | FKA + external keyboard | II — device |
| T4b · Switch Control | Switch Control | II — device (runnable there) |
| T5 · can a VoiceOver user leave? | VoiceOver, by ear | II — device |
| H · the in-hand review | a hand | II — device |

The premise checks (P1–P3) are worth more than they look: **each can falsify its test
cheaply, tonight, without hardware.** A negative is conclusive; a positive only clears the
way for Part II.

---

## Part I — simulator, runnable now

### P2 · Does `accessibilityValue` update per page turn? — ANSWERED 2026-07-26

**Yes, as far as any available instrument can testify.** Same-day walker snapshots show the
same logical element reading `Next page | Spread 1 of 9` on the first spread (seq 188, 193)
and `Next page | Spread 2 of 9` after one activation (seq 169, 174, 184) — both chevrons,
repeatedly, across relaunches. The value attribute updates per turn.

**The instrument caveat (R3):** this testifies that the *attribute changes*, not that
VoiceOver *announces* the change. The decisive half — spoken once, not zero times, not
twice — is T2, Part II. But the premise of the "PageScrolled unnecessary" reasoning is no
longer a guess: had this check failed, `PageScrolled` would have become construction-correct
tonight.

### P1 · Is the disabled chevron still in the accessibility tree? — Inspector

**Why.** `.disabled(!enabled)` was chosen on the argument that a disabled element *stays in
the tree* so focus has somewhere to rest, where a hidden one is removed and focus is
discarded. The walker already shows the disabled chevron **dropping out of the actionable
list** — which R3 says is evidence about tappability only. Whether it stays in the *AX tree*
is exactly what Accessibility Inspector reads.

**Route.** Book open (landscape — operator step), paged to **the last spread**, so
"Next page" is disabled. Inspect the trailing page-edge region.

**Prediction, pinned:** the element is **present**, with traits Button and **Not Enabled**
(Inspector may phrase it "dimmed").

**If present + Not Enabled** — the premise holds. The decisive half (where focus *goes*)
remains Part II.

**If ABSENT** — **the premise is falsified tonight, no hardware needed.** `.disabled` removes
the element just as hiding did, the focus-stability argument collapses, and the mechanism is
reconsidered — not patched. That outcome would also mean the C1 instance shipped on an
argument that was checkable all along, which goes in the row too.

### P3 · Do the chevrons carry the button trait? — Inspector, confirming the walker

The walker lists both chevrons as type `button`, which is weak evidence (its classification,
not the trait). Inspector reads traits directly. Expected: Button on both; on an interior
spread both enabled, at either boundary one Not Enabled.

### T3 · Are both MRZ bands silent? — Inspector, not the ear

**Why this instrument.** Confirming a negative by listening cannot distinguish *silent* from
*missed*. Inspector walks the real AX tree — hidden-ness becomes something read, not
something failed to be heard.

**Route (two surfaces).** (a) Book open at **the first spread** (identity page): inspect
every element. (b) Friends tab → avatar → the ID card (portrait is fine): inspect every
element.

**Observe.** Whether any element carries the raw encoding — `JOSCHKA<WAGNER<<INT<1924<…` —
as label or value. The walker still lists that string as rendered text on the identity page
(seq 188, e26), which per R3 says nothing about the AX tree; Inspector settles it.

**PASS** — the encoding is on no element on either surface, while the labelled rows (name,
handle, member since, cities, bio, holder number) are all present and correctly labelled.

**FAIL** — the encoding is exposed anywhere, or a labelled field disappeared with it.

### ⚠️ Post-Inspector net — MANDATORY before any gated work resumes

The original post-session block prescribed two nets to measure whether VoiceOver-enabled
moves pixels. **Superseded, not softened:** VoiceOver cannot be enabled in the simulator at
all, so that hazard is moot here and the question is unanswerable in this environment. The
discipline transfers to the instrument we ARE introducing:

**Accessibility Inspector's hidden state is unmeasured.** It draws element-highlight
overlays and can trigger AX activations; nobody knows whether attaching it perturbs the
framebuffer or leaves residue.

**The step:** Inspector fully closed → operator step (confirm landscape) → full pinned net
(`zur-day → zur-uv → col-uv → col-day`), hour recorded → all four must match `BASELINES.md`.
On mismatch: **stop, check instrument residue first** (Inspector still attached, wrong
spread, wrong mode, stale binary) — do not re-baseline.

---

## Part II — device (the user has an iPhone; scheduled, not deferred)

### Getting the build on

Project signing: `CODE_SIGN_STYLE = Automatic`, no team set (sim builds never needed one);
the Mac already holds `Apple Development: joschkawagner@icloud.com (A787237SC3)`, so the
account exists in Xcode. Steps: set Team on the InTouch target (Signing & Capabilities, one
dropdown) → cable + trust → Entwicklermodus on (Datenschutz & Sicherheit; reboots) → ⌘R with
the iPhone as destination → trust the developer cert (Allgemein → VPN & Geräteverwaltung).
Deployment target is **iOS 18.0** — the phone must meet it. Free-team installs expire after
7 days; rebuild restores. The MCP session here is simulator-only, so the device build goes
through Xcode by hand.

**Device prep:** rotation lock OFF (the book opens by physically rotating). Accessibility
Shortcut (triple-click) → VoiceOver. Speech rate down. **T4a needs an external Bluetooth
keyboard paired to the phone** — without one, T4a stays an honest gap and only T4b
graduates.

### T1 · Does focus survive the boundary? *(grades the shipped decision — the decisive half)*

Both boundaries, equal standing, same code path — a split is its own finding.

**Run B first (shorter route):** from the first spread, activate "Next page" once, move
focus to "Previous page", activate once — back to the first spread, and the element under
focus disables.

**Run A:** ⚠️ **REVISED 2026-07-26 after a void run — do not page the whole book.** Reach
**the second-to-last spread** by touch-exploration (rest a finger on the forward chevron,
double-tap, repeat — never swipe), focus the forward chevron, then activate **once**. One
activation, exactly symmetric with Run B.

**Why the revision.** The original phrasing said "activate repeatedly until the last spread",
and the first attempt was **VOID**: swiping between activations walked focus onto the
`DBG: CLOCK` chip, the eighth activation hit the chip instead of the chevron, and the lighting
mode toggled. Neither pinned outcome was reached, and the run measured nothing.

**The lesson, which generalises past this test: minimise traversal between the setup and the
measured event.** The eight activations were never the point — the test is the *boundary
activation*. Every element crossed on the way is an opportunity to activate the wrong thing,
and any control that changes app state (a debug chip, a mode toggle) turns a mis-activation
into silent contamination rather than an obvious error.

**Observe, both runs:** where VoiceOver focus lands immediately after the disabling
activation.

**The three outcomes, pinned in advance:**

| Outcome | Verdict |
|---|---|
| Focus stays on the disabled chevron, announced unavailable ("dimmed") | **PASS** |
| Focus moves to a sensible neighbour on the same spread | **PASS** — but apply the discriminator |
| Focus dumps to the top of the screen or is lost | **FAIL** |

**The discriminator is one more swipe.** If the next swipe continues the sequence locally,
focus was retained; if it restarts from the beginning of the screen, focus was discarded and
VoiceOver merely reset — **FAIL**, however plausible the landing spot looked. A discarded
focus and a moved focus are identical in the instant after activation; only the swipe
separates them, which is why the rule exists before the observation.

**The DECISIONS row is pre-committed, all three branches:**
- **PASS** → `.disabled` was right on the right reasoning; the UNVERIFIED label comes off;
  C1's instance upgrades to "shipped, then verified".
- **FAIL** → the afternoon's reasoning was wrong, stated plainly; the mechanism is
  reconsidered, not patched — including whether `.accessibilityHidden` was right all along.
- **SPLIT** → the row records *which* direction failed and treats it as a finding locating
  the cause outside `edgeTap`. No averaging into a verdict: a mechanism holding at one end
  has been half-falsified, not validated.

### T2 · Is the turn announced — once?

Page between interior spreads, staying focused on "Next page". P2 established the value
updates; this asks what is spoken. **PASS** — the new spread number, exactly once per turn.
**FAIL-gap** — silence → implement `PageScrolled`. **FAIL-double** — announced twice → a
different defect; do NOT add `PageScrolled`.

### T4a · Full Keyboard Access *(external keyboard required)*

Interior spread, Tab through focusable items. **PASS** — both chevrons take focus and
activate; at a boundary the disabled one is reachable but not activatable. **FAIL** — either
skipped or inert.

### T4b · Switch Control *(runnable on hardware — pass conditions restored)*

The simulator refusal was about the harness, not the test; on a real device Switch Control
is usable (screen as switch). Same shape as T4a: both chevrons reachable and activatable via
scanning; the disabled one reachable, not activatable. Untested only until the device
session runs.

### T5 · Can a VoiceOver user leave the open book?

Book open, attempt to reach any other tab by VoiceOver alone, without rotating. **PASS** — a
route out is discoverable by announcement. **FAIL** — stuck; P6 ·2 (rotate-to-close
discoverability) becomes a defect, and its design options get decided on this evidence.

### H · The in-hand review — calibration, not a test; deliberately no pass conditions

Every judgment to date was made on a simulator at arm's length. The card is authored at
~1:1 against a physical ID-1 blank (539×340 pt ≈ 85.6×54 mm); the book's UV state was judged
on a backlit desktop display. Holding both is the calibration pass before more work stacks
on screen-only judgment. Look at, without scoring:

- Does the sideways card read as **deliberate** in the hand — the no-hint decision's whole bet?
- Which turn direction feels natural (the fixed `+90` says counter-clockwise)?
- Is ~1:1 true in the hand — does it *feel* card-sized?
- The radius-only shadow: does the die-cut read hold in both holding positions?
- UV in a genuinely dark room on the OLED: do the halos composite, or smear?
- The book: page-turning rhythm, the gutter, the cover swing — held, not watched.

Observations land in DECISIONS as findings, not verdicts. If something in the hand
contradicts a screen judgment, **the hand wins and the screen judgment gets re-examined** —
that is what calibration means.

---

## Recording

One `DECISIONS.md` row per test, written the same day it runs. Part I results get rows too —
including P1's, in either direction. T1's three-branch row is pre-committed above. T4a
records the keyboard precondition if it blocks. H records observations, not verdicts.
