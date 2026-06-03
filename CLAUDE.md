# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

QuitSmoking is a SwiftUI iOS app (iOS 18.0+, iPhone-only, portrait-only) that helps users track smoke-free days. Backend is Firebase (Auth + Firestore). Swift 5, classic Xcode project (not SPM-based). Single target and scheme: `QuitSmoking`. Bundle ID: `com.stko.QuitSmoking`. Firebase config lives in `QuitSmoking/GoogleService-Info.plist` (committed).

Note: project-level build settings say deployment target 18.4, but the app target overrides to 18.0 — 18.0 is effective.

## Build & Run

```bash
open QuitSmoking.xcodeproj
# Build: Cmd+B, Run: Cmd+R
```

From CLI:
```bash
xcodebuild -project QuitSmoking.xcodeproj -scheme QuitSmoking -sdk iphonesimulator -destination 'platform=iOS Simulator,name=iPhone 16' build
```

**There are no runnable tests.** `QuitSmokingTests/` and `QuitSmokingUITests/` contain only unmodified Xcode templates and are not registered as targets in the project — `xcodebuild test` / Cmd+U has nothing to execute.

## Key Dependencies

Firebase iOS SDK 11.12+ via SPM: `FirebaseAuth`, `FirebaseFirestore`.

## Architecture

MVC-ish with SwiftUI `@Observable` models. Reactivity flows through `@Observable` classes (`SessionHandler`, `NonSmokingDaysData`), not through bindings or callbacks.

### Startup & auth routing

- `QuitSmokingApp.swift` (`@main`): `init()` calls `FirebaseApp.configure()` **then** `_sessionHandler = State(initialValue: SessionHandler())`. This order is mandatory — `SessionHandler.init()` calls `Auth.auth()`, and a `@State` default-value initializer would run before Firebase is configured and crash at launch. `AppDelegate` only requests notification permission; it does not configure Firebase.
- Root routing lives in the App `body`, not ContentView: `sessionHandler.isLoggedIn ? ContentView : SignInWith`. `SessionHandler` flips `isLoggedIn` from a Firebase `addStateDidChangeListener` — sign-in/out have no success callbacks anywhere; the auth-state listener drives all routing reactively.
- The real Apple Sign-In flow is `SignInWithAppleViewModel` in `Views/AuthView/SignInWith.swift` (SwiftUI `SignInWithAppleButton` → nonce + SHA256 → `OAuthProvider` credential → Firebase sign-in). `Controller/SignInWithAppleCoordinator.swift` is dead code — defined but never instantiated. So is `SessionData` in `SignInWith.swift`.
- `SessionHandler.signOut()` also removes scheduled notifications and clears the day-counter UserDefaults keys — duplicated there as raw string literals (`"NonSmokingDays"`, `"TrackingLastDate"`); renaming a key means editing both files.

### Day counter & sync

- Model `NonSmokingDaysData` (`@Observable`): `days: Int`, `lastTrackDate: Date`, `isLoading: Bool` (starts `true` — drives shimmer placeholders on first render).
- `NonSmokingDaysController` is a plain class created once by `ContentView` and passed to Home/Settings subviews. It syncs UserDefaults (local cache) ↔ Firestore document `users/{uid}`. The same key strings are used in both stores: `NonSmokingDays` (Int) and `TrackingLastDate`. Conflict resolution on load: max wins (local < remote → adopt remote; local > remote → push local).
- The uid is captured **once**: the controller builds its own `UserController`, which reads `Auth.auth().currentUser?.uid` in `init` and never re-reads it. If the controller is built before auth completes, uid stays `""` and every Firestore operation silently early-returns.
- Firestore writes use `setData` without `merge: true` — every save replaces the whole `users/{uid}` document. The max-wins conflict push writes only the days field, so it drops `TrackingLastDate` from the document.
- Date handling is fragile: the local date string is written/parsed with unconfigured `DateFormatter()`s and force-unwrapped, and the Firestore field is force-cast `as! Timestamp`. Tread carefully when touching `GetNonSmokingDays`/`SaveNonSmokingDays`.

### Notifications

- `NotificationManager` (singleton, `.shared`). The daily notification time is **user-configurable** (Settings DatePicker), persisted in UserDefaults under `NotificationHour`/`NotificationMinute`; 20:30 is only the default fallback.
- Scheduling is externally driven: `ContentView.onAppear` reschedules from the saved time on every appear, and Settings reschedules on time change. Rescheduling removes all pending requests then adds a fresh one (new UUID each time). The singleton's private `init` also removes all pending notifications — first access wipes the schedule, which is why the reschedule-on-appear pattern exists.
- Permission is requested in `AppDelegate`; `NotificationManager.requestAuthorization()` exists but is never called.

### Views

- `ContentView`: `NavigationStack` wrapping a `TabView` (Home, Settings); `.task` loads the counter via `GetNonSmokingDays()`.
- `Views/Home/SubViews/`: `TopBarView` (static header, reused on the sign-in screen), `MainView` (day count), `BottomView` (add-day button; long-press context menu offers Reset/Negate), `FireworksView` (Canvas + TimelineView particle overlay shown when a day is added). The fireworks re-trigger trick: `BottomView` sets `showFireworks = false` then `true` inside `DispatchQueue.main.async` so `onChange` fires even mid-burst; `FireworksView` auto-resets the binding after 3s.
- `Views/Settings/SettingsView.swift` is functional: notification-time DatePicker + Sign Out.
- `Views/Modifiers/ShimmerModifier.swift`: `.shimmer()` loading placeholder used by MainView/BottomView while `isLoading`.

## Conventions

- Methods use PascalCase (`GetNonSmokingDays`, `SaveNonSmokingDays`, `AddNonSmokingDay`, `TryGetUserInfo`) — match this when editing existing types.
- Non-idiomatic `@State` usage is load-bearing: the controller holds its model in `@State var`, and `MainView`/`BottomView` receive the shared controller into `@State` properties. This works only because a single controller instance is reused; reactivity actually comes from `NonSmokingDaysData` being `@Observable`.
