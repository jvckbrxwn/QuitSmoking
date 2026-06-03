# 03 — Verdict

## REDESIGN

**Verdict:** REDESIGN — at 12/30 the failures are structural, not cosmetic: the headline metric ("Non-smoking days") does not measure what it claims (a tap tally with no calendar guard, E-C4), four of six UI states are missing entirely (E-V5), and copy, hidden affordances, and an out-of-context permission prompt all mismatch user intent — the design must restart from the product's purpose (an honest day count), not iterate on the current surface.

Applied rule: total score 12 < 20 → REDESIGN. (Additionally #8 Thorough scored 0; the load-bearing principles #2/#4/#6 each scored 1.)

Anti-pattern check: this is not "redesign because one screen is ugly" — the 0/1 scores span measurement integrity (#2, #6), comprehension (#4), and state coverage (#8) across every screen of a three-screen app. Sunk cost is minimal by the same token: the entire view layer is ~10 small files.

## Highest-leverage moves

1. **#2 Useful + #6 Honest — make the count honest about what it measures.** *(Updated per product decision, 2026-06-03: manual tap logging is intentional and stays — the count is days the user logs, not auto-derived calendar days.)* Fix the claim side of the mismatch (E-C4): present the metric as logged days ("Smoke-free days logged"), rename "Add days" (`BottomView.swift:45`) → "Log a Day", and tie praise copy to the actual count. Optional guard that keeps taps: confirm before logging a second day on the same calendar date instead of silently incrementing (`NonSmokingDaysController.swift:91-94`).

2. **#8 Thorough — design the four missing states.** Empty (day-0 welcome/CTA instead of bare "0", `MainView.swift:25`), error (surface failures — `errorMessage` is written at `SignInWith.swift:30,38,42` and never shown; zero `.alert` repo-wide), disabled (gate "Add days" while saving/loading), and fix the user-facing grammar error in the daily notification ("track you non-smoking day", `NotificationManager.swift:107`). (E-V5, E-C3)

3. **#4 Understandable — un-hide destructive actions and de-jargon labels.** Reset/Negate exist only behind an unhinted long-press (`BottomView.swift:54-66`, E-S3/E-A3); move them to a visible, confirmed surface (Settings or swipe/menu with confirmation dialog) and rename "Negate day" → "Subtract a Day", "Last tracking change date" → "Last updated" (E-C3).

4. **#3 Aesthetic + #9 — adopt a minimal token system and honor accessibility settings.** Define AccentColor (asset currently EMPTY, `AccentColor.colorset/Contents.json`, E-V3) and derive button/icon tints from it; replace hardcoded `.system(size: 25/30)` (`MainView.swift:17,27`) and fixed 300×50 / 200×50 frames (E-A5) with Dynamic-Type-safe styles; lift `.gray` caption contrast (~2.8:1 INFERRED, `BottomView.swift:36,41`, E-V4); gate shimmer/fireworks on `accessibilityReduceMotion` (E-A5).

5. **#9 + #2 — remove launch friction.** Show the cached count immediately instead of shimmering through a Firestore round-trip (`NonSmokingDaysController.swift:23-53`, E-W3); fetch `users/{uid}` once, not twice (E-W2); ask notification permission in context (after the first logged day) instead of at process launch (`QuitSmokingApp.swift:14`, E-W5).
