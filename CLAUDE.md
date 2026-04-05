# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Commands

```bash
# Start dev server (opens QR code for Expo Go)
npm start

# Run on iOS simulator
npm run ios

# Run on Android emulator
npm run android

# Lint
npm run lint
```

No test suite is configured. There is no build step — Expo handles bundling.

## Architecture

This is a **React Native + Expo** app using a manual screen-switching pattern instead of Expo Router's file-based navigation (despite `expo-router` being installed).

### Navigation

Navigation is entirely handled in `App.tsx` via a `currentScreen` state enum. `app/_layout.tsx` just renders `<App />`, so the `app/(tabs)/` files are unused. All real screens are in `src/screens/`.

Auth gate: `AppContent` (in `App.tsx`) checks `user` from context — unauthenticated users see Welcome/Login/SignUp, authenticated users see the main screens.

### State & Auth

`src/context/AppContext.tsx` is the single global context. It wraps the whole app and exposes:
- `user`, `session`, `loading` — Supabase auth state
- `signIn`, `signUp`, `signOut` — auth methods

The context listens to `supabase.auth.onAuthStateChange` so session persists across restarts via `expo-secure-store` on iOS/Android.

### Supabase

`src/services/supabase.ts` exports a singleton `SupabaseClient` instance. All DB operations go through it. Credentials come from `.env` as `EXPO_PUBLIC_SUPABASE_URL` and `EXPO_PUBLIC_SUPABASE_ANON_KEY`.

Database tables: `profiles`, `sushi_sessions`, `sushi_types`, `friends`, `shared_meals`. All have RLS enabled. A Postgres trigger auto-creates a `profiles` row on user signup.

`getUserStats` computes stats client-side from `sushi_sessions` — `favorite_sushi` is hardcoded to `'Salmão'` (not yet derived from data).

### Screens

Screens receive navigation callbacks as props (e.g., `onBack`, `onStartSession`). There is no navigation library involved — callbacks set `currentScreen` in `App.tsx`.

| Screen | Entry point |
|--------|------------|
| `WelcomeScreen` | Unauthenticated landing |
| `NewLoginScreen` / `NewSignUpScreen` | Auth forms (old `LoginScreen`/`SignUpScreen` are unused) |
| `HomeScreen` | Dashboard with stats + action buttons |
| `SushiSessionScreen` | Timed session with per-type piece counters |
| `KeepAwakeScreen` | Single large counter with screen-wake toggle |
| `SushiListScreen` | Manage sushi types + per-type counts |

### Known TODOs

- Stats and Calendar buttons in `HomeScreen` both navigate back to `'home'` (not implemented)
- `favorite_sushi` stat is hardcoded
- `app/(tabs)/` directory is a leftover from Expo template and is not used
