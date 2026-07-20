# CLAUDE.md — InTouch

Read this first, every session. Then read `docs/PRD.md` and `docs/DESIGN.md`.

## What this is

An iOS social app where **you cannot see anyone's content unless you physically met them**.
No follows, no discovery, no algorithm, no search for strangers. The social graph is built
exclusively from verified in-person handshakes.

Tagline: **"You had to be there."**

## The one invariant

> Every piece of content is visible only to people who have proof of presence with it.

- **Friends feed** → visible only to users with a confirmed mutual handshake.
- **Group feed** → visible only to confirmed group members.
- **Event feed** → visible only to users who tapped in at that event.

This rule is enforced **server-side in Postgres Row Level Security**, never only in the app.
If a change to the app could leak content to someone without proof of presence, stop and
flag it instead of writing it.

## Stack

| Layer | Choice |
|---|---|
| UI | SwiftUI, iOS 18.0+ deployment target |
| State | `@Observable` view models (Observation framework), no external state libs |
| Backend | Supabase (Postgres + Auth + Storage + Realtime) |
| Swift SDK | `supabase-swift` via Swift Package Manager |
| Auth | Sign in with Apple |
| Handshake v1 | Rotating QR code + reciprocal FaceID (`LocalAuthentication`) |
| Handshake v2 | Physical NFC tags via CoreNFC (design for it, don't build it yet) |
| Maps | MapKit (SwiftUI `Map`) |

## Build & verify loop

XcodeBuildMCP is configured. **After every code change that touches Swift, build and check
it before saying you're done.** Never report a feature complete without a successful build.

- Build + run on simulator: `build_run_sim`
- Session defaults live in `.xcodebuildmcp/config.yaml`
- Screenshot the simulator to verify UI changes visually before reporting back
- Preferred simulator: iPhone 17

## Conventions

**Files.** One type per file, named after the type. Views end in `View`, view models end in
`Model` (e.g. `FriendsFeedView.swift`, `FriendsFeedModel.swift`).

**Structure.** `Features/<Feature>/` holds views + view models for one screen area.
`Core/` holds anything used by two or more features. If something in a feature folder gets
imported by another feature, move it to `Core/`.

**Design system.** Never write a raw hex or a raw `Font.system(...)` in a view. All colors
come from `Core/DesignSystem/Palette.swift`, all type from `Typography.swift`. If you need a
value that doesn't exist, add it to the design system first, then use it.

**Networking.** All Supabase calls go through a service in `Core/Services/`. Views never
touch the Supabase client directly.

**Swift.** Prefer `struct` over `class`. Prefer `async/await` over completion handlers.
Avoid force unwraps outside of previews. Keep views under ~150 lines; extract subviews.

## Working agreement

1. **Small increments.** One screen or one service per task. Build after each.
2. **Explain before big moves.** If a task needs a new dependency, a schema migration, or
   touches more than ~5 files, describe the plan and wait for approval.
3. **Commit at every working state**, with a clear message. The user is new to coding —
   git is the safety net.
4. **Ask instead of guessing** on product decisions. Technical decisions you can make;
   product decisions belong to the user.
5. **Update `docs/DECISIONS.md`** whenever a non-obvious technical choice is made, with a
   one-line reason.

## Do not

- Do not add analytics, ad SDKs, or third-party trackers.
- Do not add a "discover people", "suggested friends", or "trending" feature. It breaks
  the entire premise of the product.
- Do not store precise coordinates for users. City-level only. See PRD § Privacy.
- Do not store or process any third party's biometric data. FaceID is only ever used via
  `LocalAuthentication` on the device owner's own device, which returns a bare pass/fail.
- Do not commit secrets. Supabase config lives in `Config.xcconfig`, which is gitignored.
- Do not delete user content without an explicit instruction.

## Current phase

**Phase 0 — walking skeleton.** See `docs/PRD.md` § Roadmap for what's in and out.
