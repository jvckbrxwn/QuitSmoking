# 00 — Scope Lock

## What is being audited
The complete user-facing UI of the **QuitSmoking** iOS app (SwiftUI, iOS 18.0+, iPhone-only, portrait-only), audited from source — no running instance, no Figma. Visual facts derived from code are marked **INFERRED**.

Surfaces:
- **Sign-in screen** — `QuitSmoking/Views/AuthView/SignInWith.swift`
- **Root / tab shell** — `QuitSmoking/Views/ContentView.swift`, `QuitSmoking/QuitSmokingApp.swift`
- **Home (primary surface)** — `QuitSmoking/Views/Home/HomeView.swift` + `SubViews/{TopBarView, MainView, BottomView, FireworksView}.swift`, `Views/Modifiers/ShimmerModifier.swift`
- **Settings** — `QuitSmoking/Views/Settings/SettingsView.swift`
- **System-surface copy** — daily notification text in `Controller/NotificationManager.swift`, launch-time permission prompt in `QuitSmokingApp.swift` (AppDelegate)

## Primary user
A person quitting smoking who opens the app briefly, roughly once a day.

## Primary task
See the current smoke-free day count and add today as a smoke-free day.

## Constraints
- SwiftUI + Firebase (Auth, Firestore); solo developer
- Pre-publish: README lists "Prepare app for publishing" and "AdMob integration" as TBD
- No brand system beyond the app icon / accent color asset
- Audit method constraint: static source audit; contrast and rendered-pixel values are INFERRED from code

## Reference designs / competitors
None provided. (Peer context for principle #1: typical habit/streak trackers — counter + streak + celebrate.)

## Input materials
- Repo at `/Users/mac/Projects/QuitSmoking` (main, clean working tree except untracked GEMINI.md)
- Prior architecture sweep (this session) covering all view and controller files
