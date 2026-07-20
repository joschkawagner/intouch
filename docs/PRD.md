# InTouch — Product Requirements

Status: v0.1, pre-build. Owner: (you). Last updated: 20 July 2026.

---

## 1. Positioning

**The premise.** A social network where the entire graph is proof of real-life meeting.
You cannot follow, request, search for, or be recommended a stranger. The only way in is a
handshake that both people physically attended.

**Tagline.** "You had to be there."

**The status mechanic.** Most apps sell exclusivity you can buy (Amex) or virtue you can
perform (digital-detox apps). InTouch's exclusivity is *earned by presence*. A profile
showing 43 friends and 12 city stamps is a status object because everyone knows each one
cost a real evening. The velvet rope is your actual life.

**Why it spreads.** Every viral consumer app has a shareable artifact its mechanic produces
for free — Strava's route map, Duolingo's streak, Spotify Wrapped. InTouch's artifact is the
**passport**: a world map and a page of stamps. The passport is publicly shareable; the
content behind it is not. The lock is the flex.

---

## 2. Core invariant

> Content is visible only to people with proof of presence with it.

Enforced in Postgres RLS, not in the client. Three audience types:

| Feed | Audience defined by |
|---|---|
| Friends | Confirmed mutual handshake |
| Groups | Membership (every member must already be a friend of the adder) |
| Events | Tap-in during the event window |

All three are the same primitive — *a feed scoped to an audience*. Build it once.

---

## 3. The handshake

The heart of the product. Must feel like a ritual, not a form.

### v1 — QR + reciprocal FaceID

1. Both people open **Connect**. Screen goes dark navy, full-bleed — a different room.
2. Each phone displays a **one-time code, valid 60 seconds**, regenerating continuously.
3. Person A scans person B's code with the camera.
4. **Both** phones prompt FaceID simultaneously.
5. Server creates the connection only if it receives both halves within 60 seconds
   **and** both devices report coarse locations within ~100m of each other.
6. Both screens play the stamp animation together. Shared haptic. A stamp lands in both
   passports with the city name and date.

### Why this shape

- **FaceID cannot scan another person.** iOS `LocalAuthentication` only ever authenticates
  the enrolled owner of that device and returns a bare pass/fail — the app never receives
  biometric data. Scanning a third party's face would also make us a controller of special
  category biometric data under GDPR Art. 9 and the Swiss FADP. Out of the question.
- The reciprocal version proves the *real account owners* of both devices were present at
  their devices at the same moment. That is the property we actually wanted.
- **The location check is not optional.** Without it, two people on a video call can hold a
  QR code to the camera and fake a meeting. Proximity is what closes that hole.
- Be honest about the strength: v1 keeps honest people honest. Physical NFC at 4cm in v2 is
  the real lock.

### v2 — NFC

Physical tags, not phone-to-phone. Apple restricts iPhone NFC tag emulation to Secure
Element use cases (payments, keys, transit, badges, tickets) behind a paid entitlement, and
social contact exchange doesn't qualify. So: users carry a chip — card, keychain, ring —
which is on-brand for "you had to be there." Event chips at venues are unrestricted and
work today via CoreNFC.

Implement the handshake behind a `ConnectionMethod` protocol so QR → NFC is a swap, not a
rewrite.

---

## 4. Features

### 4.1 Friends
Chronological feed of posts from confirmed connections. No algorithm, ever. No likes count
shown publicly (decide later); reactions are fine. Photos + one-line captions only.

### 4.2 Groups
A named set of people who are already connected. Shared feed / album. Any member can add
someone they're connected to. Effectively a private shared album with a name.

### 4.3 Events
- An organiser creates an event: name, venue, city, start, end, **upload window**.
- Attendees tap in on site (v1: scan the event's printed QR at the door; v2: NFC chip).
- Event feed visible only to people who tapped in.
- **Upload window closes** at a set time (e.g. 06:00 after a club night). After close:
  no new uploads, but existing photos remain viewable to attendees.
- Schema carries `visible_until` (default NULL = forever) so ephemerality can be switched
  on later. Deliberately not built in v1: you can always add expiry, you can never
  un-delete.
- On close, generate a **recap card**: event name, date, "74 tapped in · 212 photos",
  blurred mosaic. Publicly shareable to Instagram stories. This is the growth loop.

### 4.4 Passport
- A **stamp** for each city where you connected with someone or attended an event.
- A **world map** with pins for every event and city.
- Stamp ink colour encodes type: Red Inferno for people, Chive for events, Navy for a
  first-ever city.
- No rarity tiers, points, or streaks in v1. The collection is enough.
- The passport page is the shareable artifact — export as an image.

### 4.5 Profile & settings
Handle, display name, avatar, friend count, stamp count. Block list. Account deletion.

---

## 5. Data model (Supabase)

```
profiles          id → auth.users, handle, display_name, avatar_url, created_at
connections       id, user_a, user_b, met_city, met_country, method, created_at
                  CHECK (user_a < user_b)   -- canonical order, no duplicate edges
handshakes        id, initiator_id, code, expires_at, claimed_by, claimed_at,
                  initiator_geo, claimer_geo, status   -- ephemeral, purged nightly
groups            id, name, created_by, created_at
group_members     group_id, user_id, added_by, joined_at
events            id, name, venue_name, city, country, lat, lng,
                  starts_at, ends_at, upload_opens_at, upload_closes_at,
                  join_code, created_by
event_attendees   event_id, user_id, tapped_in_at
posts             id, author_id, scope('friends'|'group'|'event'),
                  group_id?, event_id?, caption, created_at, visible_until NULL
post_media        id, post_id, storage_path, width, height, order_index
stamps            id, user_id, kind('city'|'event'|'person'), city, country,
                  lat, lng, earned_at, event_id?, connection_id?
reports           id, reporter_id, target_type, target_id, reason, created_at
blocks            id, blocker_id, blocked_id, created_at
```

### RLS policy sketch
- `posts` scope `friends`: readable if a row exists in `connections` pairing author with
  `auth.uid()`.
- scope `group`: readable if `auth.uid()` ∈ `group_members` for that group.
- scope `event`: readable if `auth.uid()` ∈ `event_attendees` for that event.
- INSERT on event posts: allowed only if attendee **and** `now()` between
  `upload_opens_at` and `upload_closes_at`.
- Blocked users never see each other's rows, in any scope.

---

## 6. Privacy & compliance

- **Location:** store **city + country** on connections and stamps. Coarse lat/lng
  (~1km rounded) only where the map needs it. Never a precise user trace.
- **Biometrics:** FaceID via `LocalAuthentication` only. No face data ever leaves the
  Secure Enclave, none is stored or transmitted. No third-party biometric processing.
- **GDPR / Swiss FADP:** the user is in Zürich, so both apply. Needed before any public
  release: privacy policy, data export, account deletion that actually deletes.
- **App Store Guideline 1.2** requires, for any app with user-generated content: a way to
  report content, a way to block users, a EULA, and a stated moderation response time.
  Cheap now, painful to retrofit — the `reports` and `blocks` tables exist from day one.
- **App Attest / DeviceCheck** later, to stop scripted fake accounts.

---

## 7. Out of scope for v1

Video. Text-only posts. Direct messages. Notifications beyond basic push. Android.
Discovery of any kind. Public profiles. Comments (reactions only). Ephemeral deletion.
Monetisation.

---

## 8. Roadmap

**Phase 0 — walking skeleton.** Xcode project runs. Design system implemented. Tab bar with
Friends / Groups / Events / Passport + profile. Placeholder screens with mock data. No
backend.

**Phase 1 — identity.** Supabase project, `profiles` table, Sign in with Apple, onboarding.

**Phase 2 — the handshake.** Connect screen, rotating QR, camera scan, reciprocal FaceID,
location check, `connections` written, stamp animation. *Test this with one real friend.*

**Phase 3 — friends feed.** Post composer (photo + caption), storage upload, chronological
feed, RLS policies.

**Phase 4 — events.** Create event, join via code, event feed, upload window enforcement,
recap card.

**Phase 5 — passport.** Stamp grid, then MapKit world map, then share export.

**Phase 6 — groups.** Should be a small extension of the feed primitive.

**Phase 7 — ship.** Moderation UI, privacy policy, TestFlight, real event test.

**Later.** NFC chips. Android. Ephemeral mode.

---

## 9. Open questions

- Name: **InTouch** chosen. Still to check — Swissreg and EUIPO trademark search
  (*In Touch Weekly* is an existing US magazine mark in a different class), App Store name
  availability, domain. Generic phrase = weak search discoverability; consider stylising
  as `inTouch` or `IN / TOUCH`.
- Should friend count be public, or only visible to friends?
- Who can create events — anyone, or invite-only for v1?
- Group size cap?
