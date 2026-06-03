# 01 — Evidence (consolidated from 5 subagent reports)

Static source audit; rendered-pixel values marked **INFERRED**. Anchors `E-S*` structural, `E-V*` visual, `E-C*` copy/honesty, `E-W*` weight/friction, `E-A*` accessibility.

## Structural

- **E-S1 Interactive elements**: Sign-in screen: 1 (SignInWithAppleButton, `SignInWith.swift:105-109`). Home: 1 visible button + 2 context-menu items (`BottomView.swift:44-49`, `:55-59`, `:61-65`). Settings: 2 (DatePicker `SettingsView.swift:23-31`, Sign Out `SettingsView.swift:34-41`). Tab bar: 2 (`ContentView.swift:27-36`). App total: 5 controls + 2 tabs. Very lean surface.
- **E-S2 Max nesting depth**: 9 declared containers, WindowGroup → … → "Add days" Button (`QuitSmokingApp.swift:37` → `BottomView.swift:44`).
- **E-S3 Repeated patterns**: TopBarView reused on Home + sign-in (`HomeView.swift:16`, `SignInWith.swift:103`); `.shimmer()` ×3 (`MainView.swift:22`, `BottomView.swift:27,31`); notification reschedule in 2 places (`ContentView.swift:44`, `SettingsView.swift:30`). All three counter mutations (add/reset/negate) are overloaded onto the single "Add days" button — visible tap + hidden context menu (`BottomView.swift:44-66`).
- **E-S4 Dead code in view layer**: `SettingsView.nsdController` dead prop (`SettingsView.swift:11`, only other ref is `#Preview:55`); unused `SessionData` class (`SignInWith.swift:13-15`); `errorMessage` written 3× never read (`SignInWith.swift:19,30,38,42`); commented-out stubs (`SettingsView.swift:36-39`); debug prints incl. typo "You're awsome" (`BottomView.swift:71,77`); INFERRED-unused Firebase imports (`ContentView.swift:8-10`, `MainView.swift:9`).

## Visual (INFERRED from source)

- **E-V1 Spacing scale**: no scale — literals 20, 40, 10 mixed with ≥6 default `.padding()` calls (`QuitSmokingApp.swift:39,41`, `HomeView.swift:15,17,19,23,25,26`, `MainView.swift:23,28`, `TopBarView.swift:30`, `BottomView.swift:46`, `SettingsView.swift:24,42`).
- **E-V2 Type scale**: mixed semantic + hardcoded — `.title`, `.headline`, `.caption` alongside `.system(size: 25)` (`MainView.swift:17`) and `.system(size: 30)` (`MainView.swift:27`) on the primary counter.
- **E-V3 Colors**: ad hoc — `.cyan` icon (`TopBarView.swift:16`), `.red` icon (`:25`), `.gray` captions (`BottomView.swift:36,41`), `gray.opacity(0.3)` placeholders, white-on-`.purple` button + `.purple` shadow (`BottomView.swift:47-53`), `.blue` tint (`SettingsView.swift:45`), 6-color fireworks palette (`FireworksView.swift:27`). **AccentColor asset is defined but EMPTY** — no color value (`AccentColor.colorset/Contents.json:2-6`). No named colors anywhere.
- **E-V4 Lowest contrast (INFERRED)**: `.gray` caption text ≈ **2.8:1** on assumed white background (`BottomView.swift:36,41`) — fails WCAG AA 4.5:1. White-on-purple button ≈ 3.5:1 — fails AA normal text.
- **E-V5 States checklist**:
  - empty — **MISSING** (day-0 renders as bare "0", `MainView.swift:25`; no zero-state message)
  - loading — **PRESENT** (shimmer, `MainView.swift:18-23`, `BottomView.swift:23-31`, `ShimmerModifier.swift:10-40`)
  - error — **MISSING** (zero `.alert` repo-wide; `errorMessage` never displayed; failures print-only; `fatalError` at `SignInWith.swift:35-36,66-68`)
  - success — **PRESENT** (fireworks on add, `BottomView.swift:78-81`, `FireworksView.swift:89-128`, 3s auto-dismiss)
  - focus — **MISSING/default-only** (zero `@FocusState`/`.focused` repo-wide; system defaults only)
  - disabled — **MISSING** (zero `.disabled` repo-wide; buttons tappable during async save/load)

## Copy & Honesty

- **E-C1 Inflations (2)**: "You're doing great" shown unconditionally on every screen incl. sign-in, regardless of day count (`TopBarView.swift:26`, reused `SignInWith.swift:103`); same praise hardcoded into the daily notification regardless of streak (`NotificationManager.swift:107`).
- **E-C2 Dark patterns**: none found. Mandatory Apple sign-in with no skip/guest path (`QuitSmokingApp.swift:38-42`, `SignInWith.swift:101-113`) is friction, not deception. Destructive Reset/Negate execute with **no confirmation** (`BottomView.swift:54-66`) — data-loss risk, not a dark pattern.
- **E-C3 Jargon/unclear**: "Negate day" (`BottomView.swift:61`) → "Subtract a Day"; "Last tracking change date" (`BottomView.swift:33`) → "Last updated"; notification body grammar error "track **you** non-smoking day" (`NotificationManager.swift:107`); "Add days" plural (`BottomView.swift:45`) adds exactly one; "Update notification time" reads as a button (`SettingsView.swift:23`).
- **E-C4 Label→behavior mismatches**: **the "Non-smoking days" counter measures button presses, not days** — `AddNonSmokingDay()` increments unconditionally with no calendar-day guard (`NonSmokingDaysController.swift:91-94`); repeated taps inflate the count within a minute. "Last tracking change date" shows the last-save timestamp of *any* change incl. Reset/Negate (`NonSmokingDaysController.swift:71`). "Add days" (plural) adds one.

## Weight & Friction

- **E-W1 Bundle weight**: 13 pinned SPM packages (Package.resolved) — Firestore drags gRPC 1.69.0, abseil, leveldb, nanopb, swift-protobuf, plus transitively-linked GoogleAppMeasurement (analytics; no analytics code in app). INFERRED: heavy native footprint for an app whose entire cloud state is one Int + one Date.
- **E-W2 Network on Home load**: the same `users/{uid}` document is fetched **twice** — `GetNonSmokingDays()` (`ContentView.swift:39-41` → `NonSmokingDaysController.swift:34`) and `GetTrackingLastDate()` (`BottomView.swift:68-73` → `:60`); + 0–1 conditional write (`:46`).
- **E-W3 TTI (INFERRED)**: counter is gated behind `isLoading` until the Firestore round-trip completes (`NonSmokingDaysController.swift:23,53`) — **the synchronously-available UserDefaults cache (`:24-26`) is read but not shown**; user watches shimmer for a network round-trip with no timeout.
- **E-W4 Idle animation**: 0 once loaded (shimmer torn down with `if isLoading` branch; fireworks TimelineView paused, `FireworksView.swift:96`). During load: 3 concurrent infinite `repeatForever` shimmer loops (`ShimmerModifier.swift:28-32`).
- **E-W5 Interruptions on load**: notification permission prompt fires **unconditionally at app launch**, before sign-in or any value shown (`QuitSmokingApp.swift:14`); no contextual explanation; completion handler only prints (`:16-18`).

## Accessibility (INFERRED, static)

- **E-A1 Contrast**: system-label text passes; `.gray` captions ≈2.8:1 **fail**; white-on-purple ≈3.5:1 fails AA normal text (E-V4).
- **E-A2 VoiceOver**: zero `.accessibilityLabel` / `.accessibilityHint` / `.accessibilityHidden` / header traits in the entire view layer. Decorative icons announced (`TopBarView.swift:15,24`); counter label and value not grouped (`MainView.swift:15,25`); fireworks Canvas not explicitly hidden (`FireworksView.swift:118` has only `.allowsHitTesting(false)`).
- **E-A3 Reachability**: Add day / Settings actions / sign-in reachable. **Reset and Negate are context-menu-only** with no visual hint and no alternative path (`BottomView.swift:54-66`) — INFERRED discoverable only via VoiceOver actions rotor, with no hint announcing they exist.
- **E-A4 Landmarks/grouping**: none custom; only NavigationStack titles (`ContentView.swift:26,33`) and tab Labels.
- **E-A5 Dynamic Type & motion**: hardcoded `.system(size: 25/30)` on the primary counter (`MainView.swift:17,27`); fixed frames that clip scaled text — 300×50 ×3 (`TopBarView.swift:20,29`, `SignInWith.swift:110`), 200×50 button (`BottomView.swift:50`); no `.minimumScaleFactor`/`.dynamicTypeSize` anywhere. **Reduce Motion not respected** by shimmer (`ShimmerModifier.swift:28-32`) or fireworks (no `accessibilityReduceMotion` check in either file).

## Known gaps (all agents)

No simulator/device run: contrast ratios, default padding values, TTI ms, VoiceOver order, and Dynamic Type clipping are INFERRED from source. Binary size not measured (no archive). Localization files not present/inspected. SwiftUI runtime wrapper views not countable from source.
