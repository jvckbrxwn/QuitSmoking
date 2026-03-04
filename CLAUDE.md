# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

QuitSmoking is a SwiftUI iOS app (iOS 18.0+) that helps users track smoke-free days. Backend is Firebase (Auth + Firestore). Uses Swift 5, Xcode project (not SPM-based).

## Build & Run

```bash
open QuitSmoking.xcodeproj
# Build: Cmd+B, Run: Cmd+R, Test: Cmd+U
```

From CLI:
```bash
xcodebuild -project QuitSmoking.xcodeproj -scheme QuitSmoking -sdk iphonesimulator -destination 'platform=iOS Simulator,name=iPhone 16' build
xcodebuild -project QuitSmoking.xcodeproj -scheme QuitSmoking -sdk iphonesimulator -destination 'platform=iOS Simulator,name=iPhone 16' test
```

## Architecture

MVC-ish pattern with SwiftUI:

- **Entry point**: `QuitSmoking/QuitSmokingApp.swift` — initializes Firebase, checks auth state, routes to SignIn or Home
- **Model**: `Model/NonSmokingDaysData.swift` — `@Observable` class with `days` (Int) and `lastTrackDate` (Date)
- **Controllers** (`Controller/`):
  - `NonSmokingDaysController` — day counter CRUD, syncs between UserDefaults (local cache) and Firestore (cloud). Resolves conflicts by taking max value.
  - `UserController` — wraps Firebase Auth user info
  - `NotificationManager` — singleton, schedules daily motivational notifications at 20:30
  - `SignInWithAppleCoordinator` — handles Apple Sign-In OAuth flow with Firebase
  - `SessionHandler` — observable login state flag
- **Views** (`Views/`): organized by feature — `Home/` (counter UI), `AuthView/` (sign-in), `Settings/` (WIP), `ContentView.swift` (TabView root)

## Key Dependencies

Firebase iOS SDK v11.12+ (via SPM): FirebaseAuth, FirebaseFirestore

## Data Flow

User authenticates via Apple Sign-In → Firebase Auth → UID used as Firestore document key → `NonSmokingDaysController` reads/writes to `users/{uid}` document → local UserDefaults mirrors cloud data → views observe `NonSmokingDaysData` for reactivity.

## Bundle ID

`com.stko.QuitSmoking`
