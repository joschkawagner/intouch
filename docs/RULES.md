# Rules — checks that replace judgment calls

Each entry here started as a judgment someone had to make repeatedly, and became a check
anyone can apply without re-deriving it. Add one when a decision has been made the same way
twice and the reasoning is worth more than the instance. Keep them short enough to read
before acting; the reasoning and evidence live in `DECISIONS.md`.

**Citing hashes, across all three files.** "Never truncate" is a rule about **MD5 pixel
baselines** — 32 chars, quoted whole, because a truncated baseline compares against nothing,
and that is the only place truncation has ever cost anything here. **Git commit SHAs are not
that:** they follow the repo's 7-char convention, as every row of `DECISIONS.md` already
does. Operative baseline values live in `BASELINES.md` and nowhere else.

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

### Instance 4 — the *correction* you apply to a capture is hidden state too (2026-07-26)

The first three instances were about conditions that produced the pixels. This one is about
what you do to the pixels afterwards, and it is the same failure in a new place: **a rotation
constant was pinned without naming what it depends on.**

**"Landscape" is two states, and they need opposite corrections.**
`DeviceOrientationModel.contentRotation` returns **+90° for `.landscapeLeft` and −90° for
`.landscapeRight`** — the book counter-rotates its own content to stay upright for whoever is
holding the phone. `IDCardView` instead applies a **fixed +90°** whatever the orientation,
because a card that is permanently sideways has only one state.

**So the correct viewing rotation depends on the surface AND on which landscape:**

| Surface | Content rotated by | Correct `sips --rotate` |
|---|---|---|
| ID card | `+90` always | **270** always |
| Book, sim in `.landscapeLeft` | `+90` | **270** — same as the card |
| Book, sim in `.landscapeRight` | `−90` | **90** — opposite |

The book and the card can therefore require opposite corrections *at the same moment*, and the
book's own correct value flips with an orientation nobody can see. On 2026-07-26 the book
needed 90 — which is itself the measurement that the simulator was in `.landscapeRight`.

**How it bit, twice, in mirror image.** Once on the card (`--rotate 90` where 270 was right,
producing a 180°-flipped card that sat one inference away from a false product finding), and
once on the book (`--rotate 270` where 90 was right). Both were caught by *reading the frame* —
the text came out inverted — and never by a procedure asking.

**The check:** a rotated capture is not readable until something inside it proves its
orientation. Find a text run and confirm it reads before judging anything. **Never carry a
rotation constant from one surface to another.**

**Apply it forward.** New surfaces get this question *before* their procedures are pinned.
The original wording of this line was "not after a fourth instance" — the fourth instance
landed anyway, the same day, found the same way: by accident. That is an argument for the
rule, not against it.

### Instance 6 — route A was pinned only as far as spread 2 (2026-07-28)

**The paging cadence used to reach the colophon has never been written down.** The pinned
procedure specifies the launch, the tab tap, the one tap to spread 2 and the mode toggles —
and then says only *"same for the colophon after paging."* How you get from spread 2 to
spread 9 is not part of the pin.

**Four consecutive nets agreed on that stretch because nothing happened to vary it, not
because it was controlled.** That is the whole shape of this instance: a procedure can look
reproducible for as long as the same person runs it the same way out of habit. Stability
through habit is indistinguishable from stability through control until something changes —
and the difference only shows up when you most need the measurement to be trustworthy.

**The gap is real even though the baseline is not ad hoc.** `2a864e0` shows this stretch has
at least once produced a genuine baseline: a full four-frame route A pass, with `col-day`
confirmed in the same commit as a stable regression check. So the values are earned. It is
the *route to them* that remains unpinned — and an earned value reached by an unpinned route
still cannot tell you what a mismatch means.

**Close it by writing down the actual cadence in `BASELINES.md`** the next time the colophon
is deliberately paged to. Tap count, cadence, and settle time — the same detail the first two
steps already get.

**⏸ STILL OPEN as of 2026-08-02**, said out loud so nobody reads the sentence above as
something that quietly happened. The colophon has not been deliberately paged to since this
was written.

**And P4 changed what closing it means: THE TAP COUNT IS NOT A CONSTANT, it is a formula.**
`spreadCount = cities.count + 2`, so the colophon sits at `cities.count + 1` and the walk from
spread 2 to the colophon is **`cities.count − 1` taps** — seven for the current user's
nine-spread book, which is where the *"same seven taps"* in the record comes from, and **two**
for a two-city holder, **one** for a one-city holder. Every route ever written as "Spread 9 of
9" is a current-user route wearing a number. So the cadence written into `BASELINES.md` has to
be *"tap forward until the colophon, N = cities.count − 1"*, not a count — and any route
pinned against another holder's book needs its own N.

### Instance 5 — a session was scoped against an instrument nobody checked existed (2026-07-26)

The VoiceOver session was scripted in full — five tests, instruments matched per test, pass
conditions pre-committed, setup notes down to the speech rate — and the simulator ships no
VoiceOver at all. Discovered by the operator at setup time, in Settings, where the pane
simply isn't. Full Keyboard Access is absent too, which killed a second test the same
moment. **Whether the instrument exists is part of scoping, not part of setup.** The more
care a plan invests downstream of an unchecked assumption, the more authoritative the plan
looks while being unrunnable — this script was at its most polished the moment it was
impossible.

### Instance 7 — Dynamic Type, and THE FIRST ONE FOUND BY RUNNING THE ENUMERATION (2026-08-02)

Every instance above was found by accident. This one was found by taking the list at the top of
this rule and going through it, which is what the rule has asked for since it was written.
Recording that is half the point: the method works, and nobody had used it.

**Dynamic Type is live on all four passport baselines, and `Typography.swift` says it is not.**
The section heading reads *"Passport booklet (fixed sizes — baked into the scaled page)"* and
the note says *"deliberately no Dynamic Type"* — then names its own exception in the last line:
*"City names reuse `masthead`; dates/holder-no reuse `timestamp`."* The seven `passport*` tokens
genuinely are fixed. **The reused ones are not**: `masthead`, `timestamp` and `body` all carry
`relativeTo:`, and they land on the city page, all four colophon values, both chevrons, the
identity spread, the map page — **and the `DebugUV` chip, which is in frame on every passport
baseline while not existing in a Release build at all.**

**The sharpest part is not that the comment is wrong, it is what it is wrong about.**
`PassportPage` lays out at 232×330 and `scaleEffect`s the result, so text that grows with the
user's setting grows *inside* the fixed reference — precisely the "burst the reference layout"
the note warns against, live on three tokens it never checked.

**A comment asserting a precondition is not a check of it.** That is the transferable form: the
reason nobody ran the enumeration here is that something in the code said it did not apply, and
a claim in a comment reads exactly like a result until you go looking.

### Instance 8 — the confirmation is a CONTROL, not an instrument. This one SHARPENS the rule (2026-08-02)

**Instances 1–7 are about state nobody asked about. This is about state that WAS asked about,
answered by a human, and still wrong** — which is why it belongs here as a sharpening rather
than as an eighth example.

**The mitigation R1 prescribes is the thing that failed.** `BASELINES.md` requires the agent to
stop, ask the operator to rotate the simulator, and wait for confirmation — precisely because
orientation is invisible in a portrait-locked framebuffer. On 2026-08-02 that step was followed
to the letter. The operator confirmed landscape. **The device was in portrait**, and a friend's
book came up showing a closed cover — which looked exactly like the hypothesis under test
confirming itself.

**It was not evidence, and the reason it was not is worth keeping:** two explanations predicted
the identical observation — "the device is portrait" and "the seed always fails on first read" —
the framebuffer is portrait-locked so the capture carried no signal, and **the book was the very
instrument under test**. A null run reads as a finding whenever the instrument and the subject
are the same object.

**How it was settled — with a SECOND, INDEPENDENT instrument:** the Passport tab also showed a
closed cover with all five tab targets, which by this project's own established reading means
portrait; then rotating with the book on screen swung it open, proving the observer live. So the
device had been portrait and the run had measured nothing. Discarded, not interpreted.

**THE CHECK: a confirmation lowers the odds of running in the wrong state. It does not
establish the state.** Before treating a confirmed precondition as measured, ask what
*instrument* would show it, and whether that instrument is independent of what you are testing.
If the only witness is the thing under test, you have a control, not a measurement — and a
procedure that cannot tell those apart will eventually bank a null run as a result.

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

### The sharper form — check the range before reaching for depth (2026-07-26)

The rule above forbids a UV shadow that composites *above* the ground. The stronger statement
is about how much room exists *below* it:

> **When the ground barely emits, the absence of emission barely reads.**

`uvGround` is `0x0D0714` — (13, 7, 20) of 255. That is the entire range available to any UV
shadow, before opacity is even applied. The binding shadow already sits at (9.9, 5.2, 15.1),
so driving it to the absolute floor of `uvShadow` buys **3.9 / 2.2 / 6.1** — about 2% of
channel range, across a 12pt band.

**Consequence:** on a near-black ground, depth is not a design parameter to be tuned, it is a
channel with almost nothing in it. Compute the remaining range *first*; if it is a handful of
units, no opacity value will help and rendering candidates only confirms it expensively.
Where the ground is dark, the range lives **upward** — light on the lit element, not depth in
the dark one.

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

### Sharpened on hardware, 2026-07-26 — demonstrated, no longer argued

The model above was inferred from two simulator observations. A device settled it directly:

**`.disabled(!enabled)` removed the chevron from the snapshot's `targets` list, while VoiceOver
went on seeing the very same element and announcing it as „Grau dargestellt, Taste" — "dimmed,
button".** Both were true of one element at one moment.

**So actionability and accessibility-element-ness are separate axes, and the snapshot only ever
reported the first.** That is the whole rule, now with a witness rather than an argument. An
element can be simultaneously *absent from `targets`* and *present, focusable and announced* to
assistive technology — which is precisely the reading that a disappearance in `targets` invites
and that this rule forbids.

Note what this cost before it was known: the disappearance was once read as evidence that
`.accessibilityHidden` "didn't work", a diagnosis that had to be withdrawn.

---

## R4 · Existence is not availability — verify at the control surface, not on disk

An artifact being present does not mean the capability is offered. The simulator runtime
ships `VoiceOverTouch.app`, `VoiceOver.axuiservice`, `VoiceOverServices.framework`, a
LaunchDaemon, and `VoiceOverSettings.plist` *inside the Settings bundle* — and the Settings
UI gates the pane out entirely. An existence check ("is it installed?") answers **yes** and
is worthless.

This is R3's shape in a new place: **an instrument answering a question adjacent to the one
asked.** "Are the components on disk?" is adjacent to "can a user turn this on?" — only the
control surface (the Settings UI, the menu, the actual toggle) answers the real question.

**The check:** before planning against a capability, confirm it at the surface where it
would be switched on — not by finding its binaries, not by documentation, not by memory of
other environments.

**Corollary — a check must itself be validated before it validates anything.** The same
evening, a portrait-shaped Settings screenshot was nearly adopted as an orientation check.
It proves nothing until someone establishes that Settings *rotates*: if it doesn't, the
capture is portrait in both orientations and the "check" always passes. Untested to date;
one deliberate rotation with Settings open settles it.

**⏸ STILL UNTESTED as of 2026-08-02**, stated so the sentence above is not mistaken for
something done. It is queued into the next operator trip to Settings alongside reading the
device text size (instance 7's unknown) — one trip, two answers, because both are questions
only a human standing at the simulator can answer and neither is worth a trip on its own.

**And instance 8 is this corollary's harder case.** Here the worry is a check that always
passes. There, the check *did* run, *was* answered, and was still wrong — so validating a check
means asking not only "can this ever fail?" but "is its witness independent of the thing it
witnesses?"

---

## R5 · Decorative printing is an accessibility element by default — hide it at the primitive

A document's **content** is its fields. Its **printing** is texture: microprint, guilloche,
registration marks, machine-readable bands, placeholder slots. A sighted reader tells them
apart instantly. VoiceOver cannot, because SwiftUI makes every `Text` and every `Image` an
accessibility element unless told otherwise.

**Four instances, and only two were found by asking:**

| Element | Announced as | Found by |
|---|---|---|
| Page-turn chevrons | "chevron.left" | building automation that couldn't reach them |
| Placeholder photo slots | "photo", once per collage cell | asking, during the chevron work |
| MRZ bands, both documents | the raw encoding | asking, deliberately |
| **Microprint gutter bands** | "INTOUCH · INTOUCH · …" | **hearing it on hardware** |

**The check:** treat every `Text` and `Image` in the security-printing layer as exposed until
proven otherwise. Enumerate them — do not wait to hear one. The MRZ fix was scoped to the
machine-readable band, and nobody asked whether its principle extended to the rest of the
printing layer. It did, and the gap survived four commits and a full docs pass.

**Hide at the shared primitive, not at the call site.** `MicroprintBand` has one `Text` and
three consumers (`SecurityPrinting`, `IDCardPrinting`, `IDCardFace`). One
`.accessibilityHidden(true)` covers every surface at once; three site-level fixes drift.

**⚠️ Hiding decoration is not hiding content.** When the real photo model lands, a photo in a
city page IS content and wants a label, not this modifier. The rule is about the printing
layer, not about everything that happens to be an image.

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

### ⚠️ C1 holds TWO categories, and only one of them can ever graduate

Proven by the device session on 2026-07-26 evening, which resolved one kind and left the
other exactly where it was:

- **C1a · imperceptible.** Correct by construction, but there is nothing to observe — the
  effect sits below the threshold of perception. `Color.uvShadow` is this: ~1.5% per channel
  at the spine's opacities. **No instrument will ever graduate it**, because the limit is
  perceptual, not instrumental. Its label is permanent and correct.
- **C1b · uninstrumented.** Correct by construction, there IS something to observe, but no
  instrument was available. Both MRZ bands and the `.disabled` chevron were this. **These
  graduate the moment an instrument appears** — and on 2026-07-26 a physical iPhone appeared,
  after which T3 passed outright and T1's backward boundary passed.

**Why the split is load-bearing:** a C1b item carries a debt that can be paid and should be
tracked until it is; a C1a item carries no debt at all. Filing them together makes the first
look permanently unfinished and lets the second quietly become permanent. **Decide which kind
you have before writing the label** — and if it is C1b, name the instrument that would
settle it.

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

**What still applies:** whether a change moves pixels is a separate question from whether its
effect is observable. Both instances above were pixel-checked even though their effects were
not.

> **Wording note, 2026-08-02.** This line used to say *"the pixel gate"*, which has been wrong
> since `2badb6e` demoted nets from gates to spot-checks on 2026-07-29 — nothing is gated now,
> and `docs/BASELINES.md` carries the operative framing. Corrected rather than deleted, because
> the point it makes is still true and is easy to lose: **a C1 change can be invisible to a
> human and still move a frame, so "nobody will see this" is not a reason to skip the check.**
