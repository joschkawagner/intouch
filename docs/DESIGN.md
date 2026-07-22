# InTouch — Design System

## Thesis

**The app is a passport.**

Not "a passport-themed app" — the object itself. Swiss passports are red, EU passports
burgundy; the cover is `Red Inferno`. The pages are `Coconut Milk`. Stamps land in ink.
The map colours are printed-atlas land and water. Every screen answers to that object.

This is what makes it feel unlike other apps: it's an **analog artifact**, warm and slightly
aged, not a glass dashboard. Film grain, paper texture, mechanical type. Nothing rounded and
friendly, nothing neon.

## Light, not dark

Counter-intuitive given it's used at night, but correct: a photo album is light. The paper
carries the analog soul; a dark shell would kill it.

**Exception — ceremonial moments go dark navy, full-bleed:** the Connect handshake and live
Event mode. Stepping into a dark room makes the ritual feel like a ritual. That's the whole
lighting design: cream pages, dark cover.

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

## The stamp

The signature component. Everything else can be plain if this is right.

- Circular or oval outline, weight ~2pt, deliberately slightly broken/uneven like real ink.
- Rotated 3–8° off axis, randomised per stamp but **stable** (seed from the stamp id, so it
  never jumps between renders).
- City name arcing along the top edge, date across the middle, small mark below.
- Ink colour by type: `ink` for people, `live` for events, `night` for a first-ever city.
- Lands with a press-down animation: scale from 1.15 → 1.0, quick, with a sharp haptic
  (`UIImpactFeedbackGenerator(style: .rigid)`). One thump, not a buzz.

## The collage

A profile is not a contact card — it is a **collage the person assembles themselves**: layered
photos, cut-out stickers, torn scraps of handwriting, tape, all overlapping and rotated. Events
and groups get their own collage too, set by a host or a member.

- **Loud content inside quiet order.** The collage is meant to be chaotic and personal; the app
  around it stays calm — framed on a paper page, chrome in Josefin and ink. This is the same
  rule the feed already follows ("photos carry the colour, the interface stays in the eight
  tokens"). The user's chaos sits inside the app's order, and the contrast is the point.
- **Relative coordinates, always.** Every item stores its position as `0…1` fractions of the
  collage bounds and its size as a fraction of the collage width — never absolute points. A
  collage laid out in points would drift the instant it opened on a different-sized phone;
  fractions make it compose identically on every device. This is enforced in the model
  (`Core/Models/Collage.swift`) and non-negotiable.
- **Read-only for now.** `Core/Components/CollageView.swift` renders a collage; the editor is a
  later phase. Cut-outs are clipped to the frame so they can bleed off the edge like a real
  pasted photo overhanging the page.
- Phase-0.5 stand-ins: photos are the existing generated colour blocks, stickers are simple
  palette shapes and badges, text is a handwriting hand. Real JPGs drop into `MockData` later.

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
- **Passport page:** grid of stamps on `paper`, faint printed guides in `muted`.
- **Map:** MapKit with a muted style — `muted` land, `water` water, pins as tiny stamps.
- **Empty states matter more than usual.** A new user has an empty everything. The empty
  passport should look like a *blank passport* — inviting, not broken.
