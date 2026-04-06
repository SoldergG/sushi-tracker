# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Setup

1. Copy `SushiTracker/Config.example.swift` to `SushiTracker/Config.swift` and fill in Supabase credentials.
2. Open `SushiTracker.xcodeproj` in Xcode — Swift Packages (Supabase, GoogleMobileAds) resolve automatically on first open.
3. Select an iOS simulator or device and run (⌘R).

To regenerate the Xcode project after editing `project.yml`:
```bash
xcodegen generate
```

`Config.example.swift` is excluded from compilation via `project.yml` excludes — only `Config.swift` is compiled.

## Architecture

**Swift/SwiftUI** native iOS app (iOS 16+). Backend is **Supabase** (PostgreSQL + Auth). Ads via **Google AdMob**.

### Entry point & navigation

`SushiTrackerApp.swift` initialises AdMob (`GADMobileAds.sharedInstance().start()`), creates `AuthManager.shared` as a `@StateObject`, and injects it as `@EnvironmentObject` into `ContentView`.

`ContentView` is the auth gate:
- Loading → spinner
- Not authenticated → `NavigationStack { WelcomeView() }`
- Authenticated → `NavigationStack { HomeView() }`

All navigation uses `NavigationLink` — no custom router.

### Auth

`AuthManager` (`Services/AuthManager.swift`) is a singleton `ObservableObject` on `@MainActor`. It loads the session on init via `client.auth.session` and subscribes to `client.auth.authStateChanges` for live updates. Exposes `currentUser: User?`, `isAuthenticated: Bool`, `isLoading: Bool`.

### Supabase

`SupabaseService.shared.client` holds the `SupabaseClient`. All DB calls live in `SupabaseService.swift`. Credentials come from `SupabaseConfig` (in `Config.swift`, gitignored).

DB tables: `sushi_sessions` (JSONB column `sushi_types`), `profiles`. RLS is enabled — all queries are scoped to the authenticated user's UUID.

### Models

`SushiTypeEntry` (id, name, pieces) is used both for in-memory session state and encoded as JSONB into `sushi_sessions.sushi_types`. `UserStats` is computed client-side in `SupabaseService.getUserStats`.

### Ads (`Ads/`)

| File | Role |
|------|------|
| `AdConfig.swift` | Ad unit IDs — test IDs by default, replace before release |
| `BannerAdView.swift` | `UIViewRepresentable` wrapping `GADBannerView`; adaptive width banner |
| `InterstitialAdManager.swift` | `@MainActor ObservableObject`; call `load()` at session start, `show()` at session end |

Banner placement: bottom of `HomeView` (sticky, outside the `ScrollView`).
Interstitial placement: shown once after `SushiSessionView.endSession()` completes.

### Screens

| View | Purpose |
|------|---------|
| `WelcomeView` | Dark animated landing with feature list |
| `LoginView` | Email/password sign-in |
| `SignUpView` | Name/email/password registration |
| `HomeView` | Stats grid + action buttons + sticky bottom banner |
| `SushiSessionView` | Timed session: start → grid +/- per type → end → save to DB → interstitial |
| `KeepAwakeView` | Large counter + `UIApplication.isIdleTimerDisabled` |
| `SushiListView` | Manage sushi types with +/- and delete, sheet to add new |

Shared UI: `AuthField` (dark-themed text field) and `Color(hex:)` extension live in `Views/AuthField.swift`.

### Known TODOs

- `getUserStats`: `favoriteSushi` is hardcoded to `"Salmão"`
- `HomeView.userName`: uses email prefix — should read `user_metadata.name`
- Replace AdMob test IDs in `AdConfig.swift` and `GADApplicationIdentifier` in `project.yml` before App Store release
