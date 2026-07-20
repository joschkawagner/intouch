# Decision log

One line per non-obvious technical choice, with the reason. Append, never rewrite.

| Date | Decision | Why |
|---|---|---|
| 2026-07-20 | Native SwiftUI, not React Native | The magic lives in native iOS APIs (CoreNFC, App Clips, LocalAuthentication). Cross-platform wraps exactly the parts that matter, and debugging across a bridge is brutal for a beginner. |
| 2026-07-20 | Supabase over a custom backend | Row Level Security expresses the core product invariant as a database rule, so "only attendees can see this" is enforced server-side by construction. |
| 2026-07-20 | QR handshake in v1, NFC in v2 | Apple restricts iPhone NFC tag emulation to Secure Element use cases; social contact exchange doesn't qualify. Physical chips come later behind a `ConnectionMethod` protocol. |
| 2026-07-20 | Reciprocal FaceID, not scanning the other person | `LocalAuthentication` only authenticates the device's own enrolled owner and returns pass/fail. Scanning a third party would mean processing biometric data under GDPR Art. 9. |
| 2026-07-20 | Location proximity check is mandatory | Without it a QR code can be shown over a video call, faking a meeting. Proximity is the only thing that closes that hole in v1. Doubles as the passport map data source. |
| 2026-07-20 | Event photos persist after upload window closes | Expiry can always be added; deletion can never be undone. `visible_until` exists in the schema, defaulting to NULL. |
| 2026-07-20 | Light "paper" default, dark only for rituals | The palette's soul is analog-warm and a photo album is light. Dark navy is reserved for the handshake and live events so those feel ceremonial. |
