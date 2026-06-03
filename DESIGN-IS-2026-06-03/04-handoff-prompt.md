# 04 — /make-plan Handoff

Copy-paste the block below into a fresh session. It is self-contained — no access to this audit is required.

````
/make-plan Redesign the QuitSmoking iOS app's user-facing design (all three screens: sign-in, Home counter, Settings). Current design failed a Dieter Rams ten-principles audit at 12/30 with critical gaps in principles #2 (useful, 1/3), #4 (understandable, 1/3), #6 (honest, 1/3), and #8 (thorough, 0/3).

Verdict paragraph (quoted from the audit):
> REDESIGN — at 12/30 the failures are structural, not cosmetic: the headline metric ("Non-smoking days") does not measure what it claims (a tap tally with no calendar guard), four of six UI states are missing entirely (empty, error, focus, disabled), and copy, hidden affordances, and an out-of-context permission prompt all mismatch user intent — the design must restart from the product's purpose (an honest day count), not iterate on the current surface.

Why redesign and not refine: total score 12 is far below the ≥20 refine threshold, principle #8 (thorough) scored 0, and the primary UI claim mismatches behavior — the counter increments per button press with no calendar-day guard (QuitSmoking/Controller/NonSmokingDaysController.swift:91-94) while the screen presents the number as elapsed "Non-smoking days".

PRODUCT DECISION (2026-06-03, owner): manual tap-based logging STAYS. Do NOT replace the counter with auto-derived calendar-day counting. The honesty fix routes through presentation — labels, copy, and praise must claim exactly what the tap log measures.

Context: SwiftUI, iOS 18.0+, iPhone portrait only, Firebase Auth (Sign in with Apple) + Firestore at users/{uid}, solo developer, pre-publish (AdMob planned later). Primary user: a person quitting smoking who opens the app ~once a day. Primary task: see the current count of logged smoke-free days and log today with one tap.

Preserve from current design:
- Manual tap-to-log interaction — the user logs each smoke-free day with a button press (AddNonSmokingDay, NonSmokingDaysController.swift:91-94); per product decision this model stays, including the ability to correct via subtract
- Shimmer loading pattern — ShimmerModifier.swift (Views/Modifiers/), reused via .shimmer(); well-executed and gated on isLoading
- Fireworks celebration on logging a day — Views/Home/SubViews/FireworksView.swift; Canvas+TimelineView, paused when idle, .allowsHitTesting(false), 3s auto-dismiss
- The lean interaction budget — 5 interactive controls app-wide; keep Home a single-primary-action screen
- Native system controls and reactive auth routing (SessionHandler auth-state listener driving root switch in QuitSmokingApp.swift:36-44)
- Brand: app name "Quit Smoking", app icon, healthcare-fitness category

Discard:
- The dishonest FRAMING of the tap count as elapsed days (the model itself stays per product decision). Evidence: screen presents "Non-smoking days:" (MainView.swift:15) for a count that AddNonSmokingDay() increments unconditionally per tap (NonSmokingDaysController.swift:91-94), and "Last tracking change date" (BottomView.swift:33) shows the last-save timestamp of ANY change (line 71). Caused failure on principles #2 and #6.
- Context-menu-only destructive actions (Reset Days / Negate day hidden behind an unhinted long-press on the "Add days" button, BottomView.swift:54-66, no confirmation). Caused failure on principle #4.
- Unconditional praise copy ("You're doing great" on every screen incl. sign-in, TopBarView.swift:26 reused at SignInWith.swift:103; same hardcoded praise in the daily notification regardless of streak, NotificationManager.swift:107 — which also contains the grammar error "track you non-smoking day"). Caused failure on principle #6.
- Launch-time notification permission prompt with no context (QuitSmokingApp.swift:14, fires before sign-in or first value shown). Caused failure on principle #9.
- Hardcoded type sizes and fixed frames (.system(size: 25)/(size: 30) MainView.swift:17,27; 300×50 frames TopBarView.swift:20,29 and SignInWith.swift:110; 200×50 BottomView.swift:50) and ad-hoc colors with an empty AccentColor asset (AccentColor.colorset/Contents.json has no color value). Caused failure on principles #3 and #8.

Top 5 moves from the audit (move 1 updated per the product decision; 2-5 verbatim):
1. #2 Useful + #6 Honest — make the count honest about what it measures, keeping manual taps. Present the metric as logged days ("Smoke-free days logged"), rename "Add days" (BottomView.swift:45) → "Log a Day", and tie praise copy to the actual count. Optional guard that keeps taps: confirm before logging a second day on the same calendar date (NonSmokingDaysController.swift:91-94) instead of silently incrementing.
2. #8 Thorough — design the four missing states. Empty (day-0 welcome/CTA instead of bare "0", MainView.swift:25), error (surface failures — errorMessage is written at SignInWith.swift:30,38,42 and never shown; zero .alert repo-wide), disabled (gate "Add days" while saving/loading), and fix the user-facing grammar error in the daily notification ("track you non-smoking day", NotificationManager.swift:107).
3. #4 Understandable — un-hide destructive actions and de-jargon labels. Reset/Negate exist only behind an unhinted long-press (BottomView.swift:54-66); move them to a visible, confirmed surface (Settings or swipe/menu with confirmation dialog) and rename "Negate day" → "Subtract a Day", "Last tracking change date" → "Last updated".
4. #3 Aesthetic + #9 — adopt a minimal token system and honor accessibility settings. Define AccentColor (asset currently EMPTY) and derive button/icon tints from it; replace hardcoded .system(size: 25/30) and fixed 300×50 / 200×50 frames with Dynamic-Type-safe styles; lift .gray caption contrast (~2.8:1 inferred, BottomView.swift:36,41); gate shimmer/fireworks on accessibilityReduceMotion.
5. #9 + #2 — remove launch friction. Show the cached count immediately instead of shimmering through a Firestore round-trip (NonSmokingDaysController.swift:23-53 reads UserDefaults synchronously but keeps isLoading=true until the network completes); fetch users/{uid} once, not twice (GetNonSmokingDays + GetTrackingLastDate each getDocument the same doc on load); ask notification permission in context (after the first logged day) instead of at process launch (QuitSmokingApp.swift:14).

Redesign principles in priority order:
1. #6 Honest — every label claims exactly what the tap log measures (logged days, not elapsed days); praise only when earned (tied to the actual count)
2. #2 Useful — log today in one tap with zero detours: cached count renders instantly, no forced wait, permission asked in context
3. #8 Thorough — all six states designed (empty/loading/error/success/focus/disabled); destructive actions confirmed; copy proofread
4. #4 Understandable — every action visible or conventionally discoverable; no logic jargon
5. #10 As little design as possible — keep the 5-control budget; one accent color, one type ramp, one spacing unit

Deliverables for the plan:
- New information architecture (not derived from old): screen map for sign-in → Home → Settings centered on the tap-logged day count
- New primary flow (low-fi, labeled, compared side-by-side to current): first-launch → first log → daily return visit
- Token decisions: accent color defined in asset catalog, Dynamic-Type text styles only, single spacing unit
- States checklist per screen (empty, loading, error, success, focus, disabled)
- Migration path for users currently on the old design: the data model is unchanged (NonSmokingDays Int, TrackingLastDate in UserDefaults + users/{uid}), so counts carry over as-is; only verify the relabeled UI reads existing values correctly
- Cutover criteria: old counter UI retired when the relabeled UI plus the six states ship, verified against a non-zero existing count

Anti-patterns to guard against (specific to REDESIGN):
- Renaming the button while leaving the claim mismatch elsewhere — the notification copy, praise row, and "Last tracking change date" must all align with the logged-days framing, not just the Home label
- "Fixing" honesty by sneaking in auto-derived day counting — that violates the product decision; taps stay
- Keeping both designs behind a flag indefinitely
- Redesigning to follow a trend rather than the principles above — stay on system idioms; they scored well (#7 long-lasting 2/3)
- Treating the Preserve list as optional — shimmer, fireworks, the lean control budget, and the reactive auth routing carry over
````
