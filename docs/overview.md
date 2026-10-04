# Overview — TempoShot

> **Corrected 2026-10-04.** Stack, status and constraints re-derived from
> `pubspec.yaml`, the manifests and the Gradle files.

## Project snapshot

| | |
|---|---|
| **App name** | TempoShot (Lite) · TempoShot Pro |
| **Package IDs** | `com.rutambh.temposhot` · `com.rutambh.temposhot.pro` |
| **Core idea** (owner's words) | "A dual-mode acoustic timer that acts as a firearms range shot timer (detecting gunshots/splits) and an ultra-precise metronome." |
| **Stack** | Flutter 3.44.0 / Dart 3.12.0 · Riverpod 2.6.1 · sqflite 2.4.3 · `record` 7.1.1 |
| **Target OS** | Android, `minSdk = 26` (Android 8.0) |
| **Persistence** | sqflite (raw SQLite) — **not** Drift |
| **Editions** | two, currently sharing a byte-identical `lib/` tree |
| **Status** | working prototype, not release-ready — see below |

> **Struck — two earlier claims.** The previous snapshot listed
> "Drift / SQLite" (Drift is not a dependency) and "Production Release Ready
> (APKs built for arm64-v8a and x86_64)". The release claim is not supported:
> `android/app/build.gradle.kts` sets `release { signingConfig = signingConfigs.getByName("debug") }`
> in both editions, no keystore file exists in either tree, and the documented
> output directory `D:\Apps\apks\` does not exist at all. See `cicd.md`.

> **Struck — the metronome.** The core-idea sentence above is the owner's
> original framing and is preserved verbatim, but **no metronome feature exists
> in the code**. There is no BPM control, no audio output, and no
> `features/metronome` directory. What ships today is a live-fire shot timer
> and a dry-fire par timer. Logged as an open question in `improvements.md`.

## What exists

| Capability | Evidence |
|---|---|
| Live-fire shot timer with microphone shot-break detection | [Verified] `lib/presentation/live/`, `lib/domain/engine/` |
| Dry-fire par timer with a start-beep → par-beep interval | [Verified] `lib/presentation/dryfire/` |
| Adaptive noise-floor estimator | [Verified] implemented + tested; **not wired into production** — see `architecture.md` |
| 150 ms minimum split lockout | [Verified] `AppConstants.minSplitLockoutSec` |
| Randomised 1.0–4.0 s arming delay | [Verified] `ShotDetectionEngine.armTimer` |
| String review, shot deletion, share-as-text | [Verified] `lib/presentation/summary/` |
| Local history with a 10-string Lite cap | [Verified] `TempoShotDatabase.insertStringWithShots` |
| Light + dark Field Notebook theme, 390 dp safe | [Verified] `lib/core/theme/`, widget tests |
| Sports safety disclaimer | [Verified] `lib/presentation/safety/` |

## Constraints & principles

1. **Zero Internet** — [Verified] enforced by the absence of the `INTERNET`
   permission and of every networking package. See `permissions.md`.
2. **Local-first storage** — [Verified] all records live in the sandboxed
   sqflite database; `allowBackup="false"`.
3. **Microphone released with the screen** — [Verified] via an `autoDispose`
   provider held with `ref.watch` in the live timer's `build`.
4. **No runtime network of any kind** — [Verified] fonts are bundled, not
   fetched.

## Out of scope

Cloud sync, accounts, subscriptions, telemetry, third-party analytics, and
medical or diagnostic claims.

## Verification baseline

[Verified] As of 2026-10-04, in **both** editions: `flutter analyze` reports
"No issues found!" and `flutter test` passes 49/49, exit code 0. The suites
are identical between editions.

[Verified] Not yet exercised: any real device, and any browser. See
`environment.md` for why the web test could not run on this machine.