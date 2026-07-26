# InTouch — Design System

## Thesis

**The app is a passport.**

Not "a passport-themed app" — the object itself. A **booklet you leaf through**: a cover
tinted to your home country, pages you flip city by city. Swiss passports are red, EU
passports burgundy; the cover lives in the `ink` family. The pages are `Coconut Milk`. The
map colours are printed-atlas land and water. Every screen answers to that object.

This is what makes it feel unlike other apps: it's an **analog artifact**, warm and slightly
aged, not a glass dashboard. Film grain, paper texture, mechanical type. Nothing rounded and
friendly, nothing neon.

## Light, not dark

Counter-intuitive given it's used at night, but correct: a photo album is light. The paper
carries the analog soul; a dark shell would kill it.

**Exception — ceremonial moments go dark navy, full-bleed:** the Connect handshake and live
Event mode. Stepping into a dark room makes the ritual feel like a ritual. That's the whole
lighting design: cream pages, dark cover.

**Exception — the passport has a UV/blacklight night mode.** After dark the passport
shifts to a deep black-violet ground and its printing **fluoresces**, the way real
passport pages light up under UV security ink. Landed in the 2026-07 UV design-lab pass
under one governing rule: **one object, two lighting states** — every printed element
(contours, marks, microprint, frames) exists identically in both modes; UV changes only
how they are LIT (hue, intensity, glow), never what exists or where it sits. The
saturated `stamp*` register in `Palette.swift` (+ `stampGold`) is this mode's ink set,
hue-zoned like the Swiss reference: teal/forest terrain, red machine zone (MRZ, page
keyline), gold microprint and marks, violet heroes. The contours carry the page; the
printing glows and the data stays calm (the field-glow rule — see `Palette.swift`,
UV inks). See docs/DECISIONS.md 2026-07-24/25 for the pass's decisions.

## Palette

| Token | Hex | Role |
|---|---|---|
| `paper` | `#F0EDE5` | Primary surface — feeds, passport pages |
| `ink` | `#4E0000` | Brand, passport cover, person-stamp ink, primary buttons |
| `night` | `#00344E` * | Immersive dark surface — handshake, live events |
| `text` | `#594536` | Body copy (warmer than black — never use pure black) |
| `aged` | `#F2E6B1` | Aged-paper highlight, unread/new indicators |
| `muted` | `#A1AD92` | Dividers, inactive states, map land |
| `live` | `#4A5335` * | Event live indicator, success states |
| `water` | `#94B2C4` | Map water, links, secondary accent |

\* `night` and `live` are eyeballed from the source Pantone chips (2965 C and 19-0323 TCX
Chive). Pull exact bridge values before print or App Store assets.

Source palette: Red Inferno · Pastel Yellow · Reseda · Chive · Powder Blue · Pantone 2965 C
· Cocoa · Coconut Milk.

Rule: **photos carry the colour.** The interface stays in these eight tokens and never
competes with the content.

## Typography

Two faces, chosen to do opposite jobs.

- **Display — Jost.** Everything the interface says: mastheads, navigation, labels,
  body. A cold, geometric, Bauhaus sans — deliberate. Bundled into the app (`Resources/Fonts`,
  three weights: Regular / SemiBold / Bold) under the **SIL Open Font License 1.1** (free for
  commercial use; `OFL-Jost.txt` ships alongside the fonts). Replaced Josefin Sans: Josefin's
  small x-height went spindly at tab-label size (11pt), where a geometric face has to hold on
  its own; Jost keeps the same cold-geometric character with far more presence at 11pt. Its
  larger x-height also meant the body/label sizes Josefin needed bumped could be tightened back.
- **Stamps, dates, timestamps — Courier.** Ships with iOS. Real passport stamps are struck by
  a machine, not set in a designed typeface; Courier is what makes a stamp, a date or a
  timestamp read as an *artifact* rather than a graphic. Letterspaced, slightly imperfect,
  rotated a few degrees, never centred perfectly.
- **The distinction that matters:** a **cold** geometric face (Jost — chosen; Josefin Sans,
  Futura) is correct for this brand. A **warm, rounded** geometric sans — Poppins, Circular,
  Nunito — is not; that friendliness is every other app. The line isn't "no geometric sans,"
  it's "no warm one."
- The display face is a **single constant** at the top of `Typography.swift` that every UI
  style derives from, so trialling another cold face later is a one-line change. A third face
  (a handwriting hand) appears only inside *collage content* — never in the chrome.
- **`lowercaseChrome`** (a bool in `Typography`, default `true`) renders navigation labels and
  mastheads in lowercase — Herbert Bayer argued capitals were redundant and the Bauhaus
  alphabet had none. One flag, flip it to see it both ways.
- **`chrome()` is for chrome, never for content.** `Typography.chrome()` applies the lowercase
  rule and belongs only on interface labels — tab titles, mastheads, settings rows, button
  labels. It must never transform text a user wrote or a person's or event's name.
- All type tokens live in `Core/DesignSystem/Typography.swift`. It is the only file allowed a
  raw font size.

## The stamp — retired

The procedurally-drawn stamp was once the signature component. After three lab rounds it
never read as real ink and was scrapped (see DECISIONS.md, 2026-07-22). The passport's
signature is now the **booklet** and its **auto-composed city pages** — see § The passport
booklet and § The city page below. The Courier machine typeface it used survives for
dates, timestamps and marks app-wide (see Typography).

## The passport booklet

The passport is a real booklet, not a scroll of icons. The **cover is one page**; opening it
reveals a **two-page spread** you flip through, city by city. Your own booklet is your
passport; a friend's is the passport you received from them (see PRD § 4.4–4.5).

- **⚠ UNVERIFIED RISK — the portrait two-page-spread must be prototyped before it is built.**
  A two-page spread is a landscape gesture; a phone held in portrait is tall and narrow, so
  a spread could feel cramped — two half-width pages side by side, neither readable. **Do not
  assume it works.** Prototype the spread on a real portrait phone first.
- **Fallback if the spread feels cramped:** one page at a time with a page-turn animation —
  the same leaf-through feel, one full-width page per turn, no side-by-side. This is the safe
  default the spread has to beat.
- Motion is a **page turn, not a slide** — paper folding over, mechanical, in step with the
  rest of the app's stamp-press motion (short durations, sharp easing).
- The whole booklet has a **UV/blacklight night rendering** (see § Light, not dark) — same
  pages, deep black-violet ground, the printing fluorescing. Landed in the 2026-07
  design-lab pass; driven by time of day, one object under two lighting states.

## The passport cover

One InTouch cover, **tinted into the colour *family* of the user's home-country passport** —
red, burgundy, blue, green, black — **not** a literal reproduction of a national passport.
About **five tint families** cover almost everyone, so the cover reads as "from your part of
the world" without ever copying a real government document.

- The cover **wears visibly with use over time** — creases, softened corners, a patina that
  deepens the more you travel and connect. Wear is earned; it is a status marker you cannot
  buy or fake, only accumulate by showing up (see PRD § 1). A brand-new user's cover is
  crisp and unmarked — the empty-passport state should feel *new*, not *broken*.
- **Both covers carry security printing** — the book's contour/mark vocabulary, tone-on-tone
  pale embossing by day (the real Swiss cover embosses its contours red-on-red) and
  fluorescing red contours with gold specks after dark. Real passport covers carry
  UV-reactive printing even though their pigment is dark (see DECISIONS.md 2026-07-25,
  which reversed the earlier "covers sink, nothing fluoresces" behaviour).

## The city page — Bauhaus auto-collage

Each city gets a page the **app composes automatically** — the user does not arrange it.

- Photos are laid into a **Bauhaus/Mondrian grid**: rectangles of varied size, hard edges,
  no overlap, mechanical order. This is the auto counterpart to the hand-assembled collages
  a person, host or member arranges (§ The collage) — note the profile is no longer one of
  them (§ The ID card).
- **Every cell is a photo — there is no empty-cell concept.** A city with N photos gets an
  N-cell template. Sparse cities stay *composed*: the photos occupy a deliberate part of the
  grid and the rest is bare printed page, the security printing showing through — the page
  itself is the composition, never missing content. (This supersedes BOTH earlier calls —
  solid Bauhaus-palette colour blocks, then outline-only empties; see docs/DECISIONS.md
  2026-07-24. The `bauhaus*` palette tokens are deleted with it.)
- Colour comes from the photos and their **Bauhaus frames**: every slot carries a 3pt frame
  in the `bauhaus*` register, ONE colour per page hashed stably from the city — each city
  permanently owns its frame colour. (A mixed per-cell set was tried and rejected: yellow
  advances, black recedes, and the page reads as "one cell highlighted" instead of a
  system.) Frames are daylight objects; under UV they give way to a quiet teal edge and the
  fluorescing printing is the page's colour. The surrounding chrome stays in the tokens, as
  everywhere else.

## The ID card

**Your own profile is your ID card.** Identity only — name, handle, member since, holder
number, initials, bio. No photos, no city pages, no map. Landscape ID-1, rendered *sideways
and immediately*: it is never hidden behind a rotation prompt.

The mapping is the whole point. **An ID card is identity; a passport is the record.** So your
own profile shows your ID, the Passport tab holds your book, and **a connected person's profile
shows their PASSPORT** — you receive their record, not their papers. There is deliberately no
ID for other people and no route between the two.

- **Turning is for legibility, not for opening.** The card is fully present either way. That is
  the deliberate contrast with the passport, where portrait shows a closed cover and turning the
  phone *opens* it. The card has one state; the book has two.
- **No rotate hint.** The composition has to carry "deliberately placed, not broken" on its own.
  What carries it: a radius-only shadow with no y-offset (a directional shadow declares a light
  source that is wrong in one of the two holding positions), exact symmetric margins on the
  vignetted resting surface, nothing else on screen, and chrome chosen to survive a quarter turn
  (`xmark`, `gearshape` — a chevron or a word label would break it instantly).
- **The register is inverted from the passport page.** Every VALUE is Courier, every LABEL is
  Jost, at roughly 1:1.9 against the page's 1:1.15. A page is printed and filled in; a card is
  personalised by a machine. That inversion is the strongest reason the card reads as a
  different object rather than a page turned sideways.
- **Same security printing, different composition.** Every primitive is shared with the book
  (contours, guilloché, microprint, registration marks); the *composition* is per-document and
  always will be — the page's layout is authored in 232×330 and lands wrong on a 539×340 card.
- **One fluorescing hero, as in the book:** the name. Every other value is calm, every label at
  the label floor, and the machine strip fluoresces independently because it belongs to the
  printing layer rather than the field system.
- **The portrait plate is a photo slot, not a hero** — dark and non-reactive under UV like every
  photo cell, which is both physically true and what lets the real photo model drop in later
  without redesign.

## The collage

A **collage is assembled by a person, item by item**: layered photos, cut-out stickers, torn
scraps of handwriting, tape, all overlapping and rotated. It belongs to **scan results, events
and groups** — a scanned person's collage, an event's, a group's, set by a host or a member.

**It is no longer the profile.** Your own profile is an ID card (§ The ID card). The line that
stood here — "a profile is not a contact card, it is a collage the person assembles themselves"
— was inverted by that change: the profile is now precisely a document of identity.

- **Hand-assembled here, auto-composed in the passport.** A collage is authored by a person,
  item by item. The passport's per-city pages (§ The city page) are the opposite: the app
  composes them automatically on a Bauhaus/Mondrian grid. Same visual family — overlapping
  photos, palette colour, mechanical order — but opposite authorship. The contrast survives the
  profile change; only its first pole moved, from *your profile* to *a person's, event's or
  group's collage*.
- **Loud content inside quiet order.** The collage is meant to be chaotic and personal; the app
  around it stays calm — framed on a paper page, chrome in Jost and ink. This is the same
  rule the feed already follows ("photos carry the colour, the interface stays in the eight
  tokens"). The content's chaos sits inside the app's order, and the contrast is the point.
- **Relative coordinates, always.** Every item stores its position as `0…1` fractions of the
  collage bounds and its size as a fraction of the collage width — never absolute points. A
  collage laid out in points would drift the instant it opened on a different-sized phone;
  fractions make it compose identically on every device. This is enforced in the model
  (`Core/Models/Collage.swift`) and non-negotiable.
- **Read-only for now.** `Core/Components/CollageView.swift` renders a collage; an editor is a
  later phase, and its subject is now an event's or group's collage rather than your own
  profile. Cut-outs are clipped to the frame so they can bleed off the edge like a real pasted
  photo overhanging the page.
- Stickers are simple palette shapes and badges, text is a handwriting hand. **Photos are real
  sample assets** in `MockData`, not the generated colour blocks the earlier draft of this line
  described.

## The handshake ritual

The moment the whole brand hangs on.

1. Screen fades to `night`, full-bleed, everything else recedes.
2. QR renders in `paper` on `night`, with a thin ring showing the 60s countdown.
3. On success: both phones fire the same haptic at the same instant.
4. Two stamp shapes fly together and press into the page.
5. Return to `paper` with the new stamp in the passport.

Motion should feel **mechanical, not bouncy** — a stamp press, not a spring. Short durations
(200–300ms), sharp easing curves.

## Component notes

- **Feed card:** photo full-bleed edge to edge, caption below in `text` on `paper`, small
  mechanical timestamp. No avatars cluttering the frame; a single line of attribution.
- **Passport page:** a city collage on `paper`, faint printed guides in `muted` (see § The
  city page).
- **Map:** MapKit with a muted style — `muted` land, `water` water, pins as small `ink`
  marks ringed in `paper`, not default balloons.
- **Empty states matter more than usual.** A new user has an empty everything. The empty
  passport should look like a *blank passport* — inviting, not broken.
