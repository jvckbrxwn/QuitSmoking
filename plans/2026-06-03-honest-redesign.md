# Plan: QuitSmoking Honest Redesign

Source: Rams audit verdict REDESIGN 12/30 (`DESIGN-IS-2026-06-03/`), handoff `04-handoff-prompt.md`.
**Product decision (binding):** manual tap-based logging STAYS. Never replace the counter with calendar-derived counting. Honesty fixes go through presentation. (Memory: `tap-logging-is-intentional`.)

Each phase is self-contained and executable in a fresh context. Execute consecutively; build after every phase.

Build command (no tests exist in this project — verification is build + grep + simulator):
```bash
xcodebuild -project QuitSmoking.xcodeproj -scheme QuitSmoking -sdk iphonesimulator -destination 'platform=iOS Simulator,name=iPhone 16' build
```

---

## Design Deliverables (per handoff)

### Information architecture (unchanged shell, recentered content)
```
App root (QuitSmokingApp.body, reactive on SessionHandler.isLoggedIn)
├─ Signed out: SignInWith  — TopBar(neutral tagline) + SignInWithAppleButton + error alert
└─ Signed in: ContentView — NavigationStack > TabView
   ├─ Home  — TopBar(praise tied to count) / Counter("Smoke-free days logged") or Day-0 empty state
   │          / LastUpdated caption / [Log a Day] (disabled while saving; same-day confirm)
   │          / toolbar Menu: Subtract a Day, Reset to Zero (confirmed, destructive)
   │          / fireworks overlay (Reduce Motion-gated) + success haptic
   └─ Settings — Daily reminder time (in-context permission) / Sign Out
```

### Primary flow (current → new)
| Step | Current | New |
|---|---|---|
| First launch | Permission prompt at process start, then sign-in | Sign-in only; no prompts |
| First open | Shimmer until Firestore round-trip, then "0" | Cached count instantly; day-0 empty state w/ CTA |
| First log | Tap "Add days" (plural, adds 1) | Tap "Log a Day"; fireworks + haptic; THEN in-context notification ask |
| Daily return | Counter + unconditional praise | Counter + praise earned from count; same-day re-log asks to confirm |
| Correction | Hidden long-press menu, no confirm | Visible toolbar menu, destructive confirm |

### Token decisions
- **Accent**: one brand color, deep purple `#6A35B0` (srgb 0.416/0.208/0.690) in `AccentColor.colorset` — white-on-accent ≈7.6:1 (AA pass). All tints derive from it; delete ad-hoc `.purple`/`.blue`.
- **Type**: Dynamic Type text styles only (`.largeTitle`, `.title2`, `.headline`, `.caption`); zero `.system(size:)`.
- **Spacing**: single unit — default `.padding()` and one literal (20) at window level; remove fixed text-bearing frames.

### States checklist (target: all six per screen)
empty=day-0 ContentUnavailableView · loading=existing shimmer (kept, Reduce Motion-gated) · error=alert from model `lastError` · success=fireworks (kept) + `.sensoryFeedback(.success)` · focus=system defaults (accepted; no text fields) · disabled=`.disabled(isSaving)` on Log a Day.

### Migration & cutover
Data model unchanged (`NonSmokingDays` Int + `TrackingLastDate` in UserDefaults and `users/{uid}`); counts carry over as-is. Cutover: old UI is replaced in place when Phase 6 verification passes against a non-zero pre-existing count.

---

## Phase 0 — Documentation Discovery (DONE — consolidated findings)

### Allowed APIs (verified; sources cited)
| API | Signature / form | Availability | Source |
|---|---|---|---|
| `ContentUnavailableView` | `init(label:description:actions:)` and `init(_:systemImage:description:)` | iOS 17+ | developer.apple.com/.../contentunavailableview |
| `confirmationDialog` | `(_:isPresented:titleVisibility:actions:message:)` — **no `role:` param on the modifier**; destructive goes on `Button(role: .destructive)` inside actions | iOS 15+ | developer.apple.com/.../confirmationdialog |
| `alert` | `(_:isPresented:actions:message:)`; error variant requires `E: LocalizedError` | iOS 15+ | developer.apple.com/.../alert |
| Reduce Motion | `@Environment(\.accessibilityReduceMotion) private var reduceMotion` (exact key name) | iOS 13+ | developer.apple.com/.../accessibilityreducemotion |
| `.disabled(_:)` | `func disabled(_ disabled: Bool)` | iOS 13+ | developer.apple.com/.../disabled(_:) |
| `.sensoryFeedback(_:trigger:)` | `(_ feedback: SensoryFeedback, trigger: T) where T: Equatable`; `.success` case | iOS 17+ | developer.apple.com/.../sensoryfeedback |
| `.minimumScaleFactor(_:)`, `.dynamicTypeSize(_:)` range form | per docs | iOS 13+/15+ | developer.apple.com |
| `Calendar.current.isDateInToday(_:)` | `func isDateInToday(_ date: Date) -> Bool` | iOS 8+ | Foundation docs |
| Toolbar menu | `.toolbar { ToolbarItem(placement: .topBarTrailing) { Menu { … } label: { … } } }` | `.topBarTrailing` iOS 17+ | developer.apple.com/.../menu |
| `UNUserNotificationCenter.notificationSettings()` | `async -> UNNotificationSettings` (**non-throwing**); `.authorizationStatus` ∈ `.notDetermined/.denied/.authorized/.provisional/.ephemeral` | verified in SDK headers `UNUserNotificationCenter.h:60`, `UNNotificationSettings.h:12-27` |
| `requestAuthorization(options:)` | `async throws -> Bool` | SDK header `UNUserNotificationCenter.h:53` |
| `UIApplication.openSettingsURLString` | Swift member name (global ObjC name is `UIApplicationOpenSettingsURLString`) | `UIApplication.h:613` + apinotes |
| Firestore `getDocument()` | `async throws -> DocumentSnapshot` (no source param; `getDocument(source:)` is a distinct overload) | Firebase 11.12.0 checkout `FIRDocumentReference.h:228,241` |
| `DocumentSnapshot.get(_:)` | `-> Any?` | `FIRDocumentSnapshot.h:112` |
| `Timestamp.dateValue()` | `-> Date` | `FIRTimestamp.h:63-64` |

### Global anti-patterns (apply to ALL phases)
- `.font(.system(size:))` does NOT scale with Dynamic Type — use text styles or `@ScaledMetric(relativeTo:)`.
- `.foregroundColor(_:)` is deprecated (iOS 17) — use `.foregroundStyle(_:)` everywhere you touch.
- `as!` casts on Firestore fields trap at runtime and are NOT caught by `do/catch` — always `as?`.
- Re-calling `requestAuthorization` after `.denied` does NOT re-prompt — gate on `.notDetermined`, deep-link to Settings on `.denied`.
- Asset-catalog color components are QUOTED STRINGS (`"red": "0.416"`), not raw JSON numbers — Xcode's own format.
- Match this codebase's PascalCase method convention (`GetNonSmokingDays`, `SaveNonSmokingDays`) when adding controller methods.
- **Never** add calendar-derived day counting — taps stay (product decision).

---

## Phase 1 — Honest copy & labels (strings + praise gating only)

### What to implement
Rename in place (each anchor verified verbatim by discovery):
1. `MainView.swift:15` `Text("Non-smoking days:")` → `Text("Smoke-free days logged")`
2. `BottomView.swift:45` `Text("Add days")` → `Text("Log a Day")`
3. `BottomView.swift:33` `Text("Last tracking change date")` → `Text("Last updated")`
4. `BottomView.swift:61` `Button("Negate day", …)` → `Button("Subtract a Day", …)` (menu moves in Phase 4; rename now)
5. `BottomView.swift:55` `Button("Reset Days", …)` → `Button("Reset to Zero", …)`
6. `SettingsView.swift:23` DatePicker label `"Update notification time"` → `"Daily reminder"`
7. `NotificationManager.swift:107` body `"It's time to track you non-smoking day 🚭! You're doing great!"` → `"Time to log your smoke-free day 🚭."` (typo fix; praise removed — it's unconditional there)
8. Praise tied to count: `TopBarView.swift:26` currently hardcodes `Text("You're doing great")` and TopBarView takes no data (`TopBarView.swift:11-32`; reused at `HomeView.swift:16` and `SignInWith.swift:103`). Add `var subtitle: String = "Track your smoke-free days"` to TopBarView; replace line 26 with `Text(subtitle)`. Call sites: `HomeView` passes `nsdController.nonSmokingDays.days > 0 ? "You're doing great" : "Day one starts now"`; `SignInWith` uses the default.

### Documentation references
Repo map (Phase 0): all string anchors above. No new APIs.

### Verification checklist
- Build passes.
- `grep -rn "Add days\|Negate day\|Last tracking change date\|track you non-smoking\|Update notification time" QuitSmoking/` → zero hits.
- `grep -rn "You're doing great" QuitSmoking/` → hits only in HomeView's conditional (not TopBarView, not NotificationManager).

### Anti-pattern guards
- Do NOT change any behavior in this phase — labels and the subtitle parameter only.
- Do NOT rename UserDefaults/Firestore keys (`NonSmokingDays`, `TrackingLastDate`) — they are storage contract, duplicated as raw literals in `SessionHandler.swift:31-32`.

---

## Phase 2 — Tokens & accessibility

### What to implement
1. **AccentColor**: overwrite `QuitSmoking/Assets.xcassets/AccentColor.colorset/Contents.json` (currently `{"colors":[{"idiom":"universal"}],…}` — no color block) with the verified Xcode format:
```json
{
  "colors" : [ { "idiom" : "universal", "color" : { "color-space" : "srgb", "components" : { "red" : "0.416", "green" : "0.208", "blue" : "0.690", "alpha" : "1.000" } } } ],
  "info" : { "author" : "xcode", "version" : 1 }
}
```
2. **Button → system style**: `BottomView.swift:44-53` — replace the hand-rolled white-on-`Color.purple` + `.frame(width: 200, height: 50)` + `.shadow(color: .purple…)` with `Button("Log a Day") { … }.buttonStyle(.borderedProminent).controlSize(.large)` (accent-tinted by the asset; AA-compliant white label handled by the system).
3. **Tints from accent**: `SettingsView.swift:45` remove `.tint(.blue)` (inherits accent); `TopBarView.swift:16` `.cyan` → `Color.accentColor` (keep `:24` `.red` heart — semantic).
4. **Captions**: `BottomView.swift:36,41` `.foregroundStyle(.gray)` → `.foregroundStyle(.secondary)` (adaptive, fixes ~2.8:1 INFERRED contrast).
5. **Dynamic Type**: `MainView.swift:17` `.font(.system(size: 25))` → `.font(.title2)`; `MainView.swift:27` `.font(.system(size: 30))` → `.font(.system(.largeTitle, design: .rounded, weight: .bold)).minimumScaleFactor(0.5).lineLimit(1)`.
6. **Kill clipping frames**: `TopBarView.swift:20,29` `.frame(width: 300, height: 50)` ×2 → remove (let HStacks size intrinsically, keep `.padding()`); `SignInWith.swift:110` keep (Apple control, fixed is conventional) but change to `.frame(height: 50).frame(maxWidth: 375)` if trivial. Skeleton frames (`MainView.swift:21`, `BottomView.swift:26,30`) stay — decorative.
7. **Reduce Motion**: in `ShimmerModifier.swift:28-32`, add `@Environment(\.accessibilityReduceMotion) private var reduceMotion` and skip the `withAnimation(.linear(duration: 1.5).repeatForever(autoreverses: false))` block when true (static placeholder). In `HomeView`/`FireworksView`, gate the launch: when `reduceMotion`, do not run particles (skip in `onChange(of: isActive)` at `FireworksView.swift:119-126`).
8. **VoiceOver**: `.accessibilityHidden(true)` on decorative `Image(systemName:)` at `TopBarView.swift:15,24` and on the fireworks overlay container (`HomeView.swift:27-30`); group counter: wrap MainView's label+value in `.accessibilityElement(children: .combine)`; `.accessibilityAddTraits(.isHeader)` on `TopBarView.swift:17` title.

### Documentation references
Phase 0 table: accessibilityReduceMotion env key, Font.TextStyle, minimumScaleFactor, asset JSON format (quoted strings — verified against real Xcode-generated colorsets), Color.accentColor binding via ASSETCATALOG_COMPILER_GLOBAL_ACCENT_COLOR_NAME default.

### Verification checklist
- Build passes.
- `grep -rn "\.system(size:" QuitSmoking/` → zero hits.
- `grep -rn "foregroundColor" QuitSmoking/` → zero hits (the only one was `BottomView.swift:47`, deleted with the custom button).
- `grep -rn "Color.purple\|tint(.blue)\|\.cyan" QuitSmoking/QuitSmoking/Views/` → zero hits outside `FireworksView.swift:27` (palette stays — celebration colors are intentional).
- `grep -c "accessibilityReduceMotion" QuitSmoking/` → ≥2 (shimmer + fireworks).
- Simulator: enable Reduce Motion (Settings → Accessibility) → no shimmer sweep, no fireworks; enable XXL Dynamic Type → no clipped title/counter.

### Anti-pattern guards
- Quoted-string JSON components; raw numbers break tooling.
- The environment key is `accessibilityReduceMotion` — not `reduceMotion`/`isReduceMotionEnabled`.
- Do not delete the fireworks palette or shimmer — they are on the Preserve list.

---

## Phase 3 — Missing states: empty, error, disabled (+ success haptic)

### What to implement
1. **Model** (`NonSmokingDaysData.swift`, currently `days/lastTrackDate/isLoading`): add `var isSaving: Bool = false` and `var lastError: String? = nil`.
2. **Disabled**: in `NonSmokingDaysController.SaveNonSmokingDays()` (`NonSmokingDaysController.swift:70-84`) set `nonSmokingDays.isSaving = true` at entry / `false` before every return; in `BottomView`, add `.disabled(nsdController.nonSmokingDays.isSaving || nsdController.nonSmokingDays.isLoading)` to the Log a Day button.
3. **Error surfacing**: in the controller's `catch` blocks (`NonSmokingDaysController.swift:50-52` load, `:81-83` save — currently `print` only) set `nonSmokingDays.lastError = "Couldn't sync with the cloud. Your count is saved on this device."`. In `HomeView`, present it:
```swift
.alert("Sync problem", isPresented: Binding(
    get: { nsdController.nonSmokingDays.lastError != nil },
    set: { if !$0 { nsdController.nonSmokingDays.lastError = nil } }
)) { Button("OK", role: .cancel) {} } message: { Text(nsdController.nonSmokingDays.lastError ?? "") }
```
4. **Sign-in errors**: `SignInWith.swift:19,30,38,42` — `errorMessage` is written but never read. Make `SignInWithAppleViewModel` `@Observable` (it is a plain class), hold it in `@State`, and add the same boolean-binding `.alert("Sign-in failed", …)` on the SignInWith body. Also: replace the nil-nonce `fatalError("Invalid state in AppleSignInViewModel")` at `SignInWith.swift:34-36` with `errorMessage = …; return`, and set `errorMessage` in the Firebase sign-in `catch` at `SignInWith.swift:53-55` (currently print-only). LEAVE the `fatalError` at `SignInWith.swift:66-68` alone — it is `SecRandomCopyBytes` failure inside `randomNonceString` (unrecoverable crypto failure; conventional to keep fatal).
5. **Empty / day-0**: in `MainView` (or HomeView composition), when `!isLoading && days == 0` render instead of the counter:
```swift
ContentUnavailableView {
    Label("No days logged yet", systemImage: "calendar.badge.plus")
} description: { Text("Tap “Log a Day” below to start your streak.") }
```
(`ContentUnavailableView` expands/centers — give it the MainView slot, not an inline stack position.)
6. **Success haptic**: on the counter Text (or HomeView root): `.sensoryFeedback(.success, trigger: nsdController.nonSmokingDays.days)` (iOS 17+, verified).

### Documentation references
Phase 0 table: alert signature, ContentUnavailableView inits + expansion caveat, disabled, sensoryFeedback `.success`. Repo map: catch-block and errorMessage anchors.

### Verification checklist
- Build passes.
- `grep -rn "print(" QuitSmoking/QuitSmoking/Controller/NonSmokingDaysController.swift` → catch blocks set `lastError`, not just print.
- `grep -rn "fatalError" QuitSmoking/QuitSmoking/Views/AuthView/SignInWith.swift` → only the unrecoverable nonce/window paths remain (or fewer).
- Simulator: airplane mode → log a day → alert appears, local count still increments; day-0 account → empty state renders; rapid double-tap during save → second tap ignored while disabled.

### Anti-pattern guards
- The error-presenting `alert(isPresented:error:…)` variant requires `LocalizedError` — the simple title+isPresented form with a `String?` model field (above) avoids inventing a conformance.
- `.sensoryFeedback` fires on ANY change of `days` — including Subtract/Reset. Acceptable; do not invent a `direction:` parameter (none exists).
- Don't make `isSaving` block the UI with a spinner overlay — just disable the button (unobtrusive, principle #5).

---

## Phase 4 — Visible destructive actions + same-day confirm (taps preserved)

### What to implement
1. **Delete the hidden context menu** (`BottomView.swift:54-66`) and surface the actions in a Home toolbar menu (in `HomeView` or `ContentView`'s Home tab):
```swift
.toolbar { ToolbarItem(placement: .topBarTrailing) { Menu {
    Button("Subtract a Day") { showSubtractConfirm = true }
    Button("Reset to Zero", role: .destructive) { showResetConfirm = true }
} label: { Image(systemName: "ellipsis.circle") } } }
```
2. **Confirm both** (role on the Button inside actions, never on the dialog):
```swift
.confirmationDialog("Reset your count to zero?", isPresented: $showResetConfirm, titleVisibility: .visible) {
    Button("Reset to Zero", role: .destructive) { Task { await nsdController.ResetNonSmokingDays() } }
    Button("Cancel", role: .cancel) {}
} message: { Text("This can't be undone.") }
```
(same shape for Subtract, non-destructive role.)
3. **Same-day re-log confirm** (keeps taps + backfill): in `BottomView.addNonSmokingDay` (`BottomView.swift:76-85`), before logging: if `Calendar.current.isDateInToday(nsdController.nonSmokingDays.lastTrackDate) && nsdController.nonSmokingDays.days > 0`, show a confirmationDialog "You already logged today. Add another day?" with "Add Another Day" / Cancel; otherwise log directly. KNOWN LIMITATION (document in code comment): `lastTrackDate` updates on ANY save including Subtract/Reset (`NonSmokingDaysController.swift:71`), so the prompt can occasionally appear after a same-day correction — acceptable; it only asks, never blocks.

### Documentation references
Phase 0 table: confirmationDialog exact signature + no-role-on-modifier anti-pattern, Menu/ToolbarItem `.topBarTrailing` (iOS 17+, fine on this 18.0 target), `Calendar.current.isDateInToday(_:)`. Repo map: contextMenu block and addNonSmokingDay anchors; fireworks re-trigger trick at `BottomView.swift:78-81` must survive unchanged.

### Verification checklist
- Build passes.
- `grep -rn "contextMenu" QuitSmoking/` → zero hits.
- Simulator: toolbar menu visible on Home; Reset shows red destructive confirm; logging a second time same day asks first; confirming still fires fireworks (binding toggle intact).

### Anti-pattern guards
- `confirmationDialog` has NO `role:` parameter — compile error if attempted.
- Never compare `Date`s with `==` for same-day logic — `isDateInToday` only.
- Do NOT turn the same-day confirm into a hard block (`.disabled` on already-logged-today) — that violates the taps-stay product decision; it must remain a confirm-through.

---

## Phase 5 — Friction removal: cache-first display, single fetch, in-context permission

### What to implement
1. **Cache-first**: `GetNonSmokingDays` (`NonSmokingDaysController.swift:22-54`) already reads UserDefaults synchronously (lines 24-26) but holds `isLoading = true` until the network completes (false only at 30/36/53). Insert `nonSmokingDays.isLoading = false` immediately after the UserDefaults hydration (after line 26); the Firestore block (28-52) continues as a background refresh. While here, fix the fragile date round-trip: give the instance `dateFormatter` (`:18`) a fixed format (`dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"` in init or at decl) and replace the force-unwrap parse at line 26 with `DateFormatter` reuse + nil-coalescing: `nonSmokingDays.lastTrackDate = dateStr.flatMap { dateFormatter.date(from: $0) } ?? Date.now`.
2. **Single fetch**: merge `GetTrackingLastDate` (`:56-68`) into `GetNonSmokingDays`'s existing snapshot (line 34) using verified APIs:
```swift
if let ts = snapshot.get(trackingLastDateKey) as? Timestamp {   // get(_:) -> Any?  (FIRDocumentSnapshot.h:112)
    nonSmokingDays.lastTrackDate = ts.dateValue()               // (FIRTimestamp.h:63-64)
}
```
This also kills the `as! Timestamp` trap at line 61. Delete `GetTrackingLastDate` and its only call site `BottomView.swift:68-73` (`.onAppear` Task + debug print).
3. **In-context notification permission**: delete the unconditional request in AppDelegate (`QuitSmokingApp.swift:14-20`). Add to `NotificationManager` (PascalCase to match):
```swift
@MainActor func RequestPermissionInContext() async {
    let center = UNUserNotificationCenter.current()
    let settings = await center.notificationSettings()            // async, non-throwing
    switch settings.authorizationStatus {
    case .notDetermined: _ = try? await center.requestAuthorization(options: [.alert, .badge, .sound])
    case .denied: if let url = URL(string: UIApplication.openSettingsURLString) { await UIApplication.shared.open(url) }
    default: break
    }
}
```
Call sites: (a) after the FIRST successful log — in `BottomView.addNonSmokingDay`, when the pre-log count was 0; (b) from Settings when the user touches the Daily reminder picker. Gate `ContentView.swift:42-45`'s reschedule-on-appear on `settings.authorizationStatus == .authorized` (read via `notificationSettings()`).

### Documentation references
Phase 0 table (all verified against SDK headers / Firebase 11.12.0 checkout): `notificationSettings() async` non-throwing; `requestAuthorization async throws -> Bool`; `UIApplication.openSettingsURLString`; `getDocument() async throws` (no source param); `DocumentSnapshot.get(_:)`; `Timestamp.dateValue()`.

### Verification checklist
- Build passes.
- `grep -rn "requestAuthorization" QuitSmoking/QuitSmoking/QuitSmokingApp.swift` → zero hits.
- `grep -rn "as! Timestamp\|GetTrackingLastDate" QuitSmoking/` → zero hits.
- `grep -c "getDocument" QuitSmoking/QuitSmoking/Controller/NonSmokingDaysController.swift` → 1.
- Simulator, fresh install: NO permission prompt at launch; prompt appears right after first "Log a Day"; relaunch with data → count renders instantly (no shimmer wait on network).

### Anti-pattern guards
- No-arg `getDocument()` has NO `source:` parameter (distinct overload) — and `FirestoreSource.cache` is the SDK's own cache, NOT the UserDefaults mirror; it is not needed here.
- `notificationSettings()` does not throw — no `try`.
- Re-requesting after `.denied` silently no-ops — the `.denied` branch must deep-link to Settings.
- Keep the max-wins conflict merge (lines 40-48) exactly as-is — it is documented behavior (CLAUDE.md).

---

## Phase 6 — Cleanup + Final Verification

### What to implement (cleanup)
- Delete dead code (all verified dead by repo-wide grep in the audit): `Controller/SignInWithAppleCoordinator.swift` (entire file — real flow is `SignInWithAppleViewModel` in `SignInWith.swift`); `SessionData` class (`SignInWith.swift:13-15`); `SettingsView.nsdController` dead prop (`SettingsView.swift:11` + call site `ContentView.swift:32` + `#Preview:55`); commented stubs (`SettingsView.swift:36-39`); debug prints (`BottomView.swift:71,77` — incl. the "You're awsome" typo).

### Final verification (run all)
1. Clean build: `xcodebuild … build` (command at top) — succeeds.
2. Anti-pattern grep sweep — ALL must return zero:
   - `grep -rn "Add days\|Negate day\|track you non-smoking" QuitSmoking/`
   - `grep -rn "\.system(size:\|foregroundColor\|contextMenu\|as! Timestamp" QuitSmoking/QuitSmoking/`
   - `grep -rn "SignInWithAppleCoordinator\|SessionData" QuitSmoking/`
   - `grep -rn "requestAuthorization" QuitSmoking/QuitSmoking/QuitSmokingApp.swift`
3. Regression checks for the Preserve list (handoff): shimmer still gated on `isLoading` (`grep -n "shimmer()" → 3 hits in MainView/BottomView`); fireworks still triggered by the false→true binding toggle in `addNonSmokingDay`; tap-to-log semantics unchanged (`AddNonSmokingDay` still `days += 1`, no calendar guard added — verify via `grep -n "isDateInToday" QuitSmoking/QuitSmoking/Controller/` → zero hits in the controller; the confirm lives in the view layer only).
4. Simulator pass against an account with an existing non-zero count (cutover criterion): count carries over unchanged; all six states reachable (empty via fresh account, loading on cold start, error via airplane mode, success on log, disabled during save, system focus on controls).
5. Accessibility spot-check: VoiceOver reads "Smoke-free days logged, N" as one element; Reduce Motion kills shimmer sweep + fireworks; AX5 text size doesn't clip the title or counter.

### Definition of done
Phases 1-6 merged, all greps clean, simulator checklist passes with a migrated non-zero count. The Rams re-audit targets: #6 honest ≥2, #4 understandable ≥2, #8 thorough ≥2, total ≥20 (REFINE territory).
