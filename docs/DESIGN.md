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

- **Display / stamps / dates:** a condensed grotesque or a typewriter mono. Real passport
  stamps are always mechanical type — letterspaced, slightly imperfect, often rotated a few
  degrees. Never centred perfectly.
- **Body:** a quiet serif or neutral sans at comfortable reading size.
- **Never** a rounded friendly geometric sans. That is every other app.
- All type tokens live in `Core/DesignSystem/Typography.swift`.

## The stamp

The signature component. Everything else can be plain if this is right.

- Circular or oval outline, weight ~2pt, deliberately slightly broken/uneven like real ink.
- Rotated 3–8° off axis, randomised per stamp but **stable** (seed from the stamp id, so it
  never jumps between renders).
- City name arcing along the top edge, date across the middle, small mark below.
- Ink colour by type: `ink` for people, `live` for events, `night` for a first-ever city.
- Lands with a press-down animation: scale from 1.15 → 1.0, quick, with a sharp haptic
  (`UIImpactFeedbackGenerator(style: .rigid)`). One thump, not a buzz.

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
