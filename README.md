# NumCross – Math Puzzle

Offline-first cross-math puzzle game for Android and iOS.

Intersecting equations, seeded puzzle generation, daily challenges, streaks, XP, levels, achievements, and optional Supabase sync.

## Requirements

- Flutter 3.22+ / Dart 3.3+
- Xcode (iOS) / Android Studio SDK (Android)

## Quick start

```bash
flutter pub get
flutter run
```

Gameplay works fully offline. Supabase credentials are optional.

## Branding

Production asset names live under `assets/branding/`:

| File | Use |
| --- | --- |
| `logo.png` | In-app logo |
| `app_icon.png` | Store / branding master |
| `splash_logo.png` | Native + Flutter splash logo |
| `onboarding_solve.png` | Onboarding slide 1 |
| `onboarding_levels.png` | Onboarding slide 2 |
| `onboarding_challenge.png` | Onboarding slide 3 |

Launcher icons are installed under Android `mipmap-*` and iOS `AppIcon.appiconset`.
Native splash is generated with `dart run flutter_native_splash:create` (brand `#002C92`).

Change app name, package placeholder, support URLs, and asset paths in:

`lib/app/config/app_config.dart`

Design references (not shipped in the app binary) are in `docs/design/`.

## Environment / Supabase

Keys live in the project `.env` file (gitignored):

```bash
cp .env.example .env
```

Edit `.env`:

```env
SUPABASE_URL=https://YOUR_PROJECT.supabase.co
SUPABASE_ANON_KEY=YOUR_SUPABASE_ANON_KEY
```

Then just run:

```bash
flutter run
```

The app loads these at startup via `AppConfig.load()`. If keys are empty/placeholder, it stays in offline mode. Optional override: `--dart-define=SUPABASE_URL=...` / `SUPABASE_ANON_KEY=...`.

SQL migrations: `supabase/migrations/001_initial.sql`

Never put the service role key in the Flutter client (anon key only).

## Android release

1. Create an upload keystore.
2. Copy `android/key.properties.example` → `android/key.properties` and fill it in.
3. Build:

```bash
flutter build appbundle --release
```

Application ID: `com.company.numcross`

Without `key.properties`, release builds fall back to the debug keystore for local testing only.

## iOS release

Bundle ID: `com.company.numcross`

```bash
flutter build ipa --release
```

Open `ios/Runner.xcworkspace` in Xcode to set signing team / capabilities.

## Tests & quality

```bash
flutter format .
flutter analyze
flutter test
```

## Architecture (current)

- Feature-first screens under `lib/features/`
- Shared services under `lib/core/services/` (storage, settings/sound, puzzle generator)
- Theme tokens: `lib/app/theme/app_theme.dart`
- Config: `lib/app/config/app_config.dart`
- Analytics stub: `Analytics` / `DebugAnalyticsService`
- Monetization stub: `Monetization` / `NoOpMonetizationService` (no ads in V1)

Local progress uses SharedPreferences. Drift/Supabase packages are present for the next sync iteration; core play does not depend on them.

## Puzzle generation

`PuzzleGenerator` builds intersecting equation grids from a difficulty + seed. The same seed always yields the same puzzle (`generatorVersion` in `AppConfig`). Daily challenges use a UTC date-based seed so devices stay in sync offline.

## Commands

```bash
flutter pub get
flutter run
flutter test
flutter analyze
flutter build apk --release
flutter build appbundle --release
flutter build ipa --release
```
