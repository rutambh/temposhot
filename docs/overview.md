# Overview — TempoShot

## Project Snapshot
- **App Name**: TempoShot
- **Core Tagline**: On-Device Firearms Shot Timer, Acoustic Transient Analyzer & Precision Metronome
- **Stack**: Flutter (Dart 3.x) + record / audio stream + Drift / SQLite
- **Target OS**: Android 8.0+ (API 26+) / Mobile
- **Editions**: Lite (`com.rutambh.temposhot`) & Pro (`com.rutambh.temposhot.pro`)
- **Status**: Production Release Ready (APKs built for arm64-v8a and x86_64)

## Purpose
[Verified] A dual-mode acoustic timer that acts as a firearms range shot timer (detecting gunshots/splits) and an ultra-precise metronome.
The app operates strictly on-device without cloud dependencies, accounts, subscriptions, or external analytics, ensuring complete data ownership and privacy.

## Constraints & Principles
1. **Zero Internet**: `android.permission.INTERNET` is strictly omitted from `AndroidManifest.xml` across all editions.
2. **Local-First Storage**: All data, preferences, and logs reside inside the app's sandboxed local database.
3. **Graceful Sensor Handling**: Missing sensors prompt clear UI fallbacks rather than crashing.
4. **3D Tactile Skeuomorphic UI**: Custom-rendered Canvas widgets providing physical, responsive depth.

## Out of Scope
- Cloud sync, user accounts, remote telemetry.
- Third-party advertising SDKs or tracking frameworks.
- Medical diagnosis claims (software provides informational/diary logs only).
